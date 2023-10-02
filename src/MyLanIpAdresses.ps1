Add-Type -AssemblyName System.Windows.Forms

# Créer une fenêtre Windows Forms
$form = New-Object Windows.Forms.Form
$form.Text = "Informations IP sur l'interface réseau"
$form.Width = 600
$form.Height = 200
$form.AutoScale = $true
$form.AutoSize = $true

# Créer une étiquette pour afficher du texte
$label = New-Object Windows.Forms.Label
$label.Text = "Sélectionnez une interface réseau :"
$label.Location = New-Object Drawing.Point(20, 20)
$label.AutoSize = $true

# Créer un menu déroulant (ComboBox)
$comboBox = New-Object Windows.Forms.ComboBox
$comboBox.Location = New-Object Drawing.Point(20, 50)
$comboBox.Width = 250

# Bouton pour afficher les informations IPv4
$buttonIPv4 = New-Object Windows.Forms.Button
$buttonIPv4.Location = New-Object Drawing.Point(20, 100)
$buttonIPv4.Text = "Afficher les informations IPv4"
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

            [System.Windows.Forms.MessageBox]::Show("Adresse IP : $ipAddress`nMasque de sous-réseau : $subnetMask`nPasserelle par défaut : $gateway`nAdresse MAC : $macAddress", "Informations IPv4 sur l'interface")
        } else {
            [System.Windows.Forms.MessageBox]::Show("L'interface sélectionnée n'a pas d'adresse IPv4.", "Aucune adresse IPv4")
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("Veuillez sélectionner une interface.", "Erreur")
    }
})

# Bouton pour afficher les informations IPv6
$buttonIPv6 = New-Object Windows.Forms.Button
$buttonIPv6.Location = New-Object Drawing.Point(260, 100)
$buttonIPv6.Text = "Afficher les informations IPv6"
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

            [System.Windows.Forms.MessageBox]::Show("Adresse IP : $ipAddress`nMasque de sous-réseau : $subnetMask`nPasserelle par défaut : $gateway`nAdresse MAC : $macAddress", "Informations IPv6 sur l'interface")
        } else {
            [System.Windows.Forms.MessageBox]::Show("L'interface sélectionnée n'a pas d'adresse IPv6.", "Aucune adresse IPv6")
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("Veuillez sélectionner une interface.", "Erreur")
    }
})

# Obtenir la liste des interfaces réseau avec IPv4
$networkInterfaces = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.MediaType -ne 'Loopback' -and ((Get-NetIPAddress -InterfaceAlias $_.Name -AddressFamily IPv4) -or (Get-NetIPAddress -InterfaceAlias $_.Name -AddressFamily IPv6)) } | Select-Object -ExpandProperty Name

# Ajouter les interfaces au menu déroulant
$comboBox.Items.AddRange($networkInterfaces)

# Ajouter les contrôles à la fenêtre
$form.Controls.Add($label)
$form.Controls.Add($comboBox)
$form.Controls.Add($buttonIPv4)
$form.Controls.Add($buttonIPv6)

# Afficher la fenêtre
$form.ShowDialog()

# Nettoyer la mémoire lorsque la fenêtre est fermée
$form.Dispose()
