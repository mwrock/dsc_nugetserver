include_recipe "dsc_nugetserver::resource_kit"

powershell_script "set execution policy" do
  code "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force"
end

dsc_script  "webroot" do
  code <<-EOH
    File webroot
    {
      DestinationPath="C:\\web"
      Type="Directory"
    }
  EOH
end

cookbook_file "NugetServer.zip" do
  path "#{Chef::Config[:file_cache_path]}\\NugetServer.zip"
  action :create_if_missing
end

dsc_script 'nuget web root' do
  code <<-EOH
    Archive nugetserver
    {
      ensure = 'Present'
      path = "#{Chef::Config[:file_cache_path]}\\NugetServer.zip"
      destination = "c:\\web"
    }
  EOH
end

%w{IIS-WebServerRole IIS-ISAPIFilter IIS-ISAPIExtensions NetFx4Extended-ASPNET45 IIS-NetFxExtensibility45 IIS-ASPNet45 }.each do |feature|
  dsc_resource feature do
    resource_name :xwindowsoptionalfeature
    property :name, feature
    property :nowindowsupdatecheck, true
    property :ensure, "Enable"
  end
end

dsc_resource "Remove default site" do
  resource_name :xwebsite
  property :name, "Default Web Site"
  property :ensure, "Absent"
  property :physicalpath, "c:\\inetpub\\wwwroot"
end

dsc_resource "Add Nuget site" do
  resource_name :xwebsite
  property :name, "NugetServer"
  property :ensure, "Present"
  property :state, "Started"
  property :physicalpath, "c:\\web\\NugetServer"
end

dsc_resource "http firewall rule" do
  resource_name :xfirewall
  property :name, "http"
  property :ensure, "Present"
  property :state, "Enabled"
  property :direction, "Inbound"
  property :access, "Allow"
  property :protocol, "TCP"
  property :localport, "80"
end
