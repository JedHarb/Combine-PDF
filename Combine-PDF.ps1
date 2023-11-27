if (Test-Path "C:\Program Files\gs\gswin64c.exe") {
	"Combine all PDFs in this folder to a single Combined.pdf"
	"Press any key to proceed."
	[Console]::ReadKey() > $null
	$PDFs = Get-ChildItem -File -Include *.pdf
 
	if ($PDFs) {
		if (Test-Path "Combined.pdf") {
			"You already have a Combined.pdf here. Please delete or move it and try again."
		}
		else {
			# Save the full file paths with quotation marks around each one so Ghostscript can handle spaces.
			$PDFPaths = $PDFs | ForEach-Object {"`"$_`""}
			
			$OFS = "`r`n" # Output Field Separator. Preserve newlines when an array is expressed as a string.
			"The PDFs to combine will be in this order:`n"
			$PDFs.Name
			"`nPress any key to combine now, or exit this script to cancel."
			[Console]::ReadKey() > $null
			
			# Use Ghostscript via CMD to merge all PDFs into a single one.
			& "C:\Program Files\gs\gswin64c.exe" -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile="Combined.pdf" $PDFPaths | Out-Default
				
			if ((Get-Item .\Combined.pdf).length -lt 5000) { # If Ghostscript fails to merge, it will output a very tiny (less than 5kb) pdf instead.
   				Write-Host "PDF merge failed! You may have a corrupted PDF in this folder." -ForegroundColor 'Red'
				Remove-Item .\Combined.pdf
			}
			else {
				"Finished"
				if ((Read-Host "If you want to delete ALL source PDFs now, please enter the letter 'Y'") -eq "Y") {
					$PDFs | Remove-Item # Delete the source PDFs after merge.
     					"Deleted"
     				}
			}
		}
	}
	else {
		"No PDFs found in this folder."
	}
}
else {
	"Could not locate C:\Program Files\gs\gswin64c.exe"
	"Please install Ghostscript and make sure this file exists (or edit this script to point to the Ghostscript exe)."
}
[Console]::ReadKey() > $null # Pause script (waiting for any user input) so any of the above messages don't immediately close.
