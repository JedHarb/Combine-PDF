if ($GS = Get-ChildItem -Path "C:\Program Files\gs\" -Recurse -Include gswin*.exe | Sort-Object LastWriteTime -Descending | Select-Object -First 1) {
	if ($PDFs = Get-ChildItem -Path .\* -File -Include *.pdf) {
		"Ready to combine all PDFs in this folder to a single Combined.pdf"
		"Press any key to review."
		[Console]::ReadKey() > $null
		
		if (Test-Path "Combined.pdf") {
			"`nYou already have a Combined.pdf here. Please delete or move it and try again."
		}
		else {
			# Save the full file paths with quotation marks around each one so Ghostscript can handle spaces.
			$PDFPaths = $PDFs | ForEach-Object {"`"$_`""}
			
			$OFS = "`r`n" # Output Field Separator. Preserve newlines when an array is expressed as a string.
			"`nThe PDFs to combine will be in this order:`n"
			$PDFs.Name
			"`nPress any key to combine now, or exit this script to cancel."
			[Console]::ReadKey() > $null
			
			# Use Ghostscript via CMD to merge all PDFs into a single one.
			& $GS -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile="Combined.pdf" $PDFPaths | Out-Default
				
			if ((Get-Item .\Combined.pdf).length -lt 5000) { # If Ghostscript fails to merge, it will output a very tiny (less than 5kb) pdf instead.
   				Write-Host "PDF merge failed! You may have a corrupted PDF in this folder." -ForegroundColor 'Red'
				Remove-Item .\Combined.pdf
			}
			else {
				"`nCombined!"
				if ((Read-Host "If you want to delete all of the source PDFs now, please enter the letter 'Y'") -eq "Y") {
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
	"Could not locate an exe anywhere inside C:\Program Files\gs\"
	"Please install Ghostscript and make sure this file exists (or edit this script to point to the Ghostscript exe)."
}
"Finished. Press any key to exit."
[Console]::ReadKey() > $null # Pause script (waiting for any user input) so any of the above messages don't immediately close.
