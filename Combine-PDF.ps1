"Combine all PDFs in this folder to a single Combined.pdf"
"Press any key to continue."
[Console]::ReadKey() > $null

$PDFs = Get-ChildItem * -File -Include *.pdf

if (Test-Path "C:\Program Files\bioPDF\PDF Writer\gs\gswin64c.exe") {
	if ($PDFs) {
		if (Test-Path "Combined.pdf") {
			"You already have a Combined.pdf here! Please delete, move, or rename it and try again."
		}
		else {
			# Save the full file paths with quotation marks around each one so Ghostscript can handle spaces.
			$PDFPaths = $PDFs | ForEach-Object {"`"$_`""}
			
			$OFS = "`r`n" # Output Field Separator. Specifies the character that separates the elements of an array when the array is converted to a string. (preserve newlines when writing the array)
			"The PDFs to combined will be in this order:`n"
			$PDFs.Name
			"`nPress any key to continue."
			[Console]::ReadKey() > $null
			
			# Use Ghostscript via CMD to merge all PDFs into a single one.
			& "C:\Program Files\bioPDF\PDF Writer\gs\gswin64c.exe" -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile="Combined.pdf" $PDFPaths | Out-Default
				
			if ((Get-Item .\Combined.pdf).length -gt 5000) { # Make sure the resulting PDF is greater than 5kb
				$PDFs | Remove-Item # Delete the source PDFs after merge.
				"Finished"
			}
			else { # If Ghostscript fails to merge, it will output a very small (less than 5kb) pdf instead.
				Write-Host "PDF merge failed! You may have a corrupted PDF in this folder." -ForegroundColor 'Red'
				Remove-Item .\Combined.pdf
			}
		}
	}
	else {
		"No PDFs found in this folder."
	}
}
else {
	"Could not locate C:\Program Files\bioPDF\PDF Writer\gs\gswin64c.exe"
	"Please install Ghostscript and make sure this file exists (or edit this script to point to the file)."
}
[Console]::ReadKey() > $null # Pause script (waiting for any user input) so any of the above messages don't immediately close.