remote_file "#{ENV['temp']}/filezilla.exe" do
  source 'http://downloads.sourceforge.net/project/filezilla/FileZilla%20Server/0.9.46/FileZilla_Server-0_9_46.exe'
end

# dsc_script "filezilla package" do
#   code <<-EOH
#     Package Filezilla
#     {
#       Ensure = "Present"
#       Name="FileZilla Server"
#       Path="#{ENV['temp']}/filezilla.exe"
#       ProductId=''
#       Arguments="/S "
#     }
#   EOH
# end

windows_package 'filezilla' do
  source "#{ENV['temp']}/filezilla.exe"
  action :install
end

install_path = "#{ENV['ProgramFiles']}\\FileZilla Server"

powershell_script 'FileZilla Firewall Rule' do
  code <<-EOS
    New-NetFirewallRule -DisplayName "FileZilla Server" -Direction Inbound -LocalPort Any -Protocol TCP -Action Allow -EdgeTraversalPolicy Block -Program "#{install_path}\\FileZilla Server.exe"

EOS
  guard_interpreter :powershell_script
  not_if "Get-NetFirewallRule -DisplayName \"FileZilla Server\"; return $?"
end

dsc_script "user" do
  code <<-EOH
    User FTPUser
    {
      UserName="FTPUser"
    }
  EOH
end

dsc_script "group" do
  code <<-EOH
    Group administrators
    {
      GroupName="administrators"
      MembersToInclude="FTPUser"
    }
  EOH
end

dsc_script  "ftproot" do
  code <<-EOH
    File ftproot
    {
      DestinationPath="C:\\FtpRoot"
      Type="Directory"
    }
  EOH
end
