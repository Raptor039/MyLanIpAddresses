Add-Type -AssemblyName System.Windows.Forms

# Create Windows Forms Window
$form = New-Object Windows.Forms.Form
$form.Text = "IP informations on network interface"
$form.Width = 600
$form.Height = 200
$form.AutoScale = $true
$form.AutoSize = $true

# Create label to display text
$label = New-Object Windows.Forms.Label
$label.Text = "Select a network interface :"
$label.Location = New-Object Drawing.Point(20, 20)
$label.AutoSize = $true

# Create ComboBox
$comboBox = New-Object Windows.Forms.ComboBox
$comboBox.Location = New-Object Drawing.Point(20, 50)
$comboBox.Width = 250

# Button to display IPv4 informations
$buttonIPv4 = New-Object Windows.Forms.Button
$buttonIPv4.Location = New-Object Drawing.Point(20, 100)
$buttonIPv4.Text = "Show IPv4 informations"
$buttonIPv4.AutoSize = $true
$buttonIPv4.Add_Click({
    $selectedInterface = $comboBox.SelectedItem
    if ($selectedInterface) {
        $ipv4Addresses = Get-NetIPAddress -InterfaceAlias $selectedInterface -AddressFamily IPv4
        
        if ($ipv4Addresses) {
            $ipAddress = $ipv4Addresses.IPAddress
            $subnetMask = $ipv4Addresses.PrefixLength
            $gateway = (Get-NetRoute -InterfaceAlias $selectedInterface -AddressFamily IPv4 | Where-Object { $_.DestinationPrefix -eq '0.0.0.0/0' }).NextHop
            $macAddress = (Get-NetAdapter -InterfaceAlias $selectedInterface).MacAddress

            [System.Windows.Forms.MessageBox]::Show("IP Address : $ipAddress`nNetmask : $subnetMask`nDefault gateway : $gateway`nMAC Address : $macAddress", "IPv4 informations of this network interface")
        } else {
            [System.Windows.Forms.MessageBox]::Show("Selected interface has no IPv4 address.", "IPv4 address not found")
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("Select a network interface.", "Error")
    }
})

# Button to display IPv6 informations
$buttonIPv6 = New-Object Windows.Forms.Button
$buttonIPv6.Location = New-Object Drawing.Point(260, 100)
$buttonIPv6.Text = "Show IPv6 informations"
$buttonIPv6.AutoSize = $true
$buttonIPv6.Add_Click({
    $selectedInterface = $comboBox.SelectedItem
    if ($selectedInterface) {
        $ipv6Addresses = Get-NetIPAddress -InterfaceAlias $selectedInterface -AddressFamily IPv6
        
        if ($ipv6Addresses) {
            $ipAddress = $ipv6Addresses.IPAddress
            $subnetMask = $ipv6Addresses.PrefixLength
            $gateway = (Get-NetRoute -InterfaceAlias $selectedInterface -AddressFamily IPv6 | Where-Object { $_.DestinationPrefix -eq '::/0' }).NextHop
            $macAddress = (Get-NetAdapter -InterfaceAlias $selectedInterface).MacAddress

            [System.Windows.Forms.MessageBox]::Show("IP Address : $ipAddress`nNetmask : $subnetMask`nDefault gateway : $gateway`nMAC Address : $macAddress", "IPv6 informations of this network interface")
        } else {
            [System.Windows.Forms.MessageBox]::Show("Selected interface has no IPv6 address.", "IPv6 address not found")
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("Please select a network interface.", "Error")
    }
})

# Get up/active network interface list (IPv4 or IPv6)
$networkInterfaces = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.MediaType -ne 'Loopback' -and ((Get-NetIPAddress -InterfaceAlias $_.Name -AddressFamily IPv4) -or (Get-NetIPAddress -InterfaceAlias $_.Name -AddressFamily IPv6)) } | Select-Object -ExpandProperty Name

# Add interfaces list to ComboBox
$comboBox.Items.AddRange($networkInterfaces)

# Add controls to Window
$form.Controls.Add($label)
$form.Controls.Add($comboBox)
$form.Controls.Add($buttonIPv4)
$form.Controls.Add($buttonIPv6)

# Display Window
$form.ShowDialog()

# Cleanup memory when window is closed
$form.Dispose()
