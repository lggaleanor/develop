#Este script tiene el objetivo de asignar un usuario de windows a la ejecución de servicios.

$services=Get-Service | Select-Object Name | Where-Object Name -Match "Nombre del servicio" # Reemplazar por el nombre de servicio que debe de buscar.

$credential = Get-Credential -Credential Domain\user01 #reemplazar por el dominio y usuario correcto.

for ($i = 0; $i -lt $services.Length; $i++  ){
    Stop-Service -Name $services[$i].name
    Set-Service -Name $services[$i].name -Credential $credential
    Start-Service -Name $services[$i].name
} 