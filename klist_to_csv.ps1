# Run the klist command and store the output in the $klistOutput variable
$klistOutput = klist | out-string

# Remove empty lines from the output
$klistOutput = $klistOutput | Where-Object { $_ -match '\S' }

# Define a pattern to match each ticket using regex
$pattern = @"
#(?<Ticket>\d+>)\s*Client:\s*(?<Client>[^@]+) @ (?<Domain>[^\n]+)
(?:\s*Server:\s*(?<Server>[^\n]+))?
(?:\s*KerbTicket Encryption Type:\s*(?<KerbTicketEncryptionType>[^\n]+))?
(?:\s*Ticket Flags\s*(?<TicketFlags>0x[^\n]+)\s*->\s*(?<TicketFlagDescriptions>[^\n]+))?
(?:\s*Start Time:\s*(?<StartTime>[^\n]+))?
(?:\s*End Time:\s*(?<EndTime>[^\n]+))?
(?:\s*Renew Time:\s*(?<RenewTime>[^\n]+))?
(?:\s*Session Key Type:\s*(?<SessionKeyType>[^\n]+))?
(?:\s*Cache Flags:\s*(?<CacheFlags>[^\n]+))?
(?:\s*Kdc Called:\s*(?<KdcCalled>[^\n]+))?
"@

# Use regex to extract each ticket and create objects for each ticket
$tickets = [regex]::Matches($klistOutput, $pattern) | ForEach-Object {
    [PSCustomObject]@{
        Ticket                  = $_.Groups['Ticket'].Value
        Client                  = $_.Groups['Client'].Value.Trim()
        Domain                  = $_.Groups['Domain'].Value.Trim()
        Server                  = $_.Groups['Server'].Value.Trim()
        KerbTicketEncryptionType= $_.Groups['KerbTicketEncryptionType'].Value.Trim()
        TicketFlags             = $_.Groups['TicketFlags'].Value.Trim()
        TicketFlagDescriptions  = $_.Groups['TicketFlagDescriptions'].Value.Trim()
        StartTime               = $_.Groups['StartTime'].Value.Trim()
        EndTime                 = $_.Groups['EndTime'].Value.Trim()
        RenewTime               = $_.Groups['RenewTime'].Value.Trim()
        SessionKeyType          = $_.Groups['SessionKeyType'].Value.Trim()
        CacheFlags              = $_.Groups['CacheFlags'].Value.Trim()
        KdcCalled               = $_.Groups['KdcCalled'].Value.Trim()
    }
}

# Export the data to a CSV file
$tickets | Export-Csv -Path "klist_output.csv" -NoTypeInformation

Write-Host "Conversion completed successfully!"

