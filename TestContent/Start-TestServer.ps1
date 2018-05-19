$serverOpts = @{
    Path = Join-Path -Path $PSScriptRoot -ChildPath "Server"
    Image = "jetbrains/teamcity-server:latest-windowsservercore"
    IP = "192.168.1.18"
    Name = "teamcity-server-instance"
}

$agentPath = Join-Path -Path $PSScriptRoot -ChildPath "Agent"
$agentImage = "jetbrains/teamcity-agent:latest-windowsservercore"

#docker run -it --name "$($serverOpts.Name)"  --network=nat -p 8080:8111 -v "$($serverOpts.Path)\Data:C:/ProgramData/JetBrains/TeamCity" -v "$($serverOpts.Path)\Logs:C:/TeamCity/Logs" "$($serverOpts.Image)"
docker run -it --name "$($serverOpts.Name)" -p 8080:8111 -v "$($serverOpts.Path)\Data:C:/ProgramData/JetBrains/TeamCity" -v "$($serverOpts.Path)\Logs:C:/TeamCity/Logs" "$($serverOpts.Image)"

# remove the container
docker container rm "$($serverOpts.Name)"