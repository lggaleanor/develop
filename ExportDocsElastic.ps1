Param(
    [Parameter(Mandatory=$true)]
    [String] $urlElastic , # URL de elastic junto con el puerto http://hostname:port
    [Parameter(Mandatory=$true)]
    [String] $nombreIndice  ,
    [Parameter(Mandatory = $true)]
    [String] $pathCSV
)

$urlElasticCount = $urlElastic+'/'+ $nombreIndice + '/_count'
$urlElasticSearch = $urlElastic+'/'+ $nombreIndice + '/_search'

$TotalDocuments = Invoke-RestMethod $urlElasticCount -Method 'GET' -Headers $headers
$TotalDocuments = $TotalDocuments.count

$numeroIteraciones = $TotalDocuments/10000
$numeroIteraciones = [math]::Round($numeroIteraciones)

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")

    $body = "{
    `n  `"size`": 1,
    `n  `"sort`": [ 
    `n    {`"createdOn`": `"asc`"}
    `n  ]
    `n}"

    $response = Invoke-RestMethod $urlElasticSearch -Method 'POST' -Headers $headers -Body $body
    $response.hits.hits._source | Export-Csv -Path $pathCSV -Append
    $BuscarDespues = $response.hits.hits.sort

for ($i=0 ; $i -le $numeroIteraciones; $i++ ){

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/json")

    $body = "{
    `n  `"size`": 10000,    
    `n  `"sort`": [ 
    `n    {`"createdOn`": `"asc`"}
    `n  ],
    `n  `"search_after`": [                                
    `n    $BuscarDespues
    `n  ]
    `n}"

    $response = Invoke-RestMethod $urlElasticSearch -Method 'POST' -Headers $headers -Body $body
    $response.hits.hits._source | Export-Csv -Path $pathCSV -Append
    $BuscarDespues = $response.hits.hits.sort[10000-1]
}
