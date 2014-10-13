describe "default recipe" {

  it "should expose a nuget packages feed" {
    $packages = Invoke-RestMethod -Uri "http://localhost/nuget/Packages"
    $packages.Count | should not be 0
    $packages[0].Title.InnerText | should be 'elmah'
  }

  context "firewall" {

    $rule = Get-NetFirewallRule | ? { $_.InstanceID -eq 'http' }
    $filter = Get-NetFirewallPortFilter | ? { $_.InstanceID -eq 'http' }

    it "should filter port 80" {
      $filter.LocalPort | should be 80
    }
    it "should be enabled" {
      $rule.Enabled | should be $true
    }
    it "should allow traffic" {
      $rule.Action | should be "Allow"
    }
    it "should apply to inbound traffic" {
      $rule.Direction | should be "Inbound"
    }    
  }
}