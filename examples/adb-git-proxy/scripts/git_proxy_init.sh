#!/bin/bash
set -x
#--------------------------------------------------
mkdir /databricks/dp_git_proxy
cat >/databricks/dp_git_proxy/dp_git_proxy.py <<EOF
from http.server import HTTPServer, BaseHTTPRequestHandler
import sys
import urllib3
from base64 import b64encode
http = urllib3.PoolManager()
def str_to_b64(s):
    return b64encode(bytes(s, 'ascii')).decode('ascii')
def make_authorization(username, token):
    return "Basic {}".format(str_to_b64(username + ":" + token))
class DPProxyRequestHandler(BaseHTTPRequestHandler):
    def _proxy_response(self, response):
        self.send_response(response.status)
        for k in response.headers:
            if (k.lower() == "transfer-encoding"):
                # TODO: no chunking for now
                self.send_header(k, "identity")
            elif (k.lower() == "connection"):
                self.send_header(k, "close")
            else:
                self.send_header(k, response.headers[k])
        self.end_headers()
        self.wfile.write(response.data)
    def do_GET(self):
        url = "https:/{}".format(self.path)
        print("do_GET: {}".format(url))

        username = self.headers.get('X-Git-User-Name')
        token = self.headers.get('X-Git-User-Token')
        headers = {
            "Accept": self.headers.get('Accept'),
            "Authorization": make_authorization(username, token),
        }

        provider = self.headers.get('X-Git-User-Provider')
        if provider not in ['gitLab', 'gitLabEnterpriseEdition']:
            headers["Accept-Encoding"] = self.headers.get('Accept-Encoding')

        response = http.request('GET', url, headers=headers)
        self._proxy_response(response)
    def do_POST(self):
        url = "https:/{}".format(self.path)
        print("do_POST: {}".format(url))
        content_len = int(self.headers.get('Content-Length', 0))
        username = self.headers.get('X-Git-User-Name')
        token = self.headers.get('X-Git-User-Token')
        post_body = self.rfile.read(content_len)
        headers = {
            "Accept": self.headers.get('Accept'),
            "Accept-Encoding": self.headers.get('Accept-Encoding'),
            "Authorization": make_authorization(username, token),
            "Cache-Control": self.headers.get('Cache-Control'),
            "Connection": self.headers.get('Connection'),
            "Content-Encoding": self.headers.get('Content-Encoding'),
            "Content-Type": self.headers.get('Content-Type'),
            "Pragma": self.headers.get('Pragma'),
            "User-Agent": self.headers.get('User-Agent'),
        }
        response = http.request('POST', url, body=post_body, headers=headers)
        self._proxy_response(response)
    def do_HEAD(self):
        raise Exception("HEAD not supported")
if __name__ == '__main__':
    server_address = ('', int(sys.argv[1]) if len(sys.argv) > 1 else 8000)
    print("Data-plane proxy server binding to {} ...".format(server_address))
    httpd = HTTPServer(server_address, DPProxyRequestHandler)
    httpd.serve_forever()
EOF
#--------------------------------------------------
cat >/etc/systemd/system/gitproxy.service <<EOF
[Service]
Type=simple
ExecStart=/databricks/python3/bin/python3 -u /databricks/dp_git_proxy/dp_git_proxy.py
StandardInput=null
StandardOutput=file:/databricks/dp_git_proxy/daemon.log
StandardError=file:/databricks/dp_git_proxy/daemon.log
Restart=always
RestartSec=1

[Unit]
Description=Git Proxy Service

[Install]
WantedBy=multi-user.target
EOF
#--------------------------------------------------
systemctl daemon-reload
systemctl enable gitproxy.service
systemctl start gitproxy.service
