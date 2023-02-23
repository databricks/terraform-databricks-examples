[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $OrganizationUri,

    [Parameter(Mandatory=$true)]
    [string]
    $Project,

    [Parameter(Mandatory=$true)]
    [string]
    $PersonAccessToken,

    [Parameter(Mandatory=$true)]
    [string]
    $RepositoryId,

    [Parameter(Mandatory=$true)]
    [string]
    $PullRequestId,

    [Parameter(Mandatory=$true)]
    [string]
    $BuildId,

    [Parameter(Mandatory=$true)]
    [string]
    $TerraformPlanCommand
)

try {
    $planOutput = Invoke-Expression -Command $TerraformPlanCommand

    $basicAuth =  "basic user:$PersonAccessToken"

    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes( $basicAuth  ) )

    $headers = @{
        Authorization = "Basic $Base64AuthInfo"
    }

    $newThreadEndpoint = "$( $OrganizationUri )/$( $Project )/_apis/git/repositories/$( $RepositoryId )/pullRequests/$( $PullRequestId )/threads?api-version=6.0"

    $newThreadEndpoint

    $content = "# Requested infrastructe updates`r`n" + `
                "This comment was added automatically by build validation pipeline " + `
                "to help DevOps team review **what will change** after completing this PR.`r`n`r`n`r`n`r`n " + `
                "Empty output below means there are no changes to apply.`r`n`r`n " 

    $content += "``````"
    
    $includeLineSwitch = $false

    foreach ($item in $planOutput) {
        if (-not $includeLineSwitch) {
            $includeLineSwitch = $item -like "*Terraform used the selected providers to generate the following execution*"
        }
        
        if ($includeLineSwitch) {
            $content += "`r`n$( $item )" 
        }
    }
    
    $content += "`r`n``````"

    $newThread = @{
        Comments = @(
            @{
                ParentCommentId = 0
                Content         = $content
                CommentType     = "text"
            }
        )
        Status = "Active"
    } 

    $newThreadBody = $newThread | ConvertTo-Json -Depth 10

    $newThreadBody 

    $thread = Invoke-RestMethod -Uri $newThreadEndpoint -Headers $headers  -Method Post -Body $newThreadBody -ContentType 'application/json'

    $thread
}
catch {
    Get-Error
    Write-Error -Message "Failed to add plan ad PR comment"
}