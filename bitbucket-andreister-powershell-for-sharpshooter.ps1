###############################################################
#
# Generates the report from .rst file and displays it.
#
###############################################################
function Show-Report($file)
{
	###########################################################################
	# Helper function to display the generated report in a separate window.
	###########################################################################
	function displayGeneratedReport()
	{
		#This function is an event handler, but the normal signature "xxx($sender, $e)" doesn't work for some reason, 
		#and the report source is stored in $this variable (instead of $sender as you might expect).
		$source = [PerpetuumSoft.Reporting.Components.IReportSource]$this
		if ($source.Manager.OwnerForm -ne $null) { $source.Manager.OwnerForm.Close() }

		try {
			$preview = new-object PerpetuumSoft.Reporting.View.PreviewForm($source)
			$preview.WindowState = [System.Windows.Forms.FormWindowState]"Maximized";
			$preview.ShowDialog() 
		} 
		finally {
			if ($preview -ne $null) {
				if ($preview.psbase -ne $null) { $preview.psbase.Dispose() } 
				else { $preview.Dispose() }
			}
		}
	}

	###########################################################################
	# Helper function to load all the necessary assemblies.
	###########################################################################
	function loadAssemblies()
	{
		$programFiles = ${env:ProgramFiles}
		if ([IntPtr]::Size -eq 8) { $programFiles = ${env:ProgramFiles(x86)} } 
		$binaries = join-path $programFiles "Perpetuum Software\Net ModelKit Suite\Bin"
		if (!(test-path $binaries)) {
			#maybe it's RSS6.0 or later
			$binaries = join-path $programFiles "Perpetuum Software\SharpShooter Collection\Bin"
		}
		[System.Reflection.Assembly]::LoadFrom("$binaries\PerpetuumSoft.Reporting.dll") | out-null
		if ([System.IO.File]::ReadAllText($reportFile).Contains("Reporting.MSChart.MicrosoftChart")) {
			[System.Reflection.Assembly]::LoadFrom("$binaries\PerpetuumSoft.Reporting.MSChart.dll") | out-null 
		}
		[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | out-null    
	}
	
	###########################################################################
	# Helper function to create all components necessary for displaying a report.
	###########################################################################
	function createReportSlot($reportFile)
	{
		loadAssemblies

		#The "owner" form is required as otherwise SharpShooter cannot correctly operate its threads. 
		#We make the form hidden because, in fact, no user interaction is required on the form - everything is done by the script.
		$form = new-object System.Windows.Forms.Form
		$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]"FixedToolWindow"
		$form.ShowInTaskbar = $false
		$form.StartPosition = [System.Windows.Forms.FormStartPosition]"Manual"
		$form.Location = new-object System.Drawing.Point(-2000, -2000)
		$form.Size = new-object System.Drawing.Size(1, 1)    
		$form.Text = "Hidden form to generate SharpShooter reports from Powershell"

		$reportSlot = new-object PerpetuumSoft.Reporting.Components.FileReportSlot
		$reportSlot.FilePath = $reportFile
		
		$reportManager = new-object PerpetuumSoft.Reporting.Components.ReportManager
		$reportManager.DataSources = new-object PerpetuumSoft.Reporting.Components.ObjectPointerCollection
		$reportManager.Reports.Add([PerpetuumSoft.Reporting.Components.ReportSlot]$reportSlot)
		$reportManager.OwnerForm = $form;
			
		return $reportSlot
	}    
	
	###########################################################################
	# Main part of Show-Report function.
	###########################################################################
	$reportSlot = (createReportSlot -reportFile:$file)[0] #for some reason, powershell wraps the result in an array
	$ownerForm = $reportSlot.Manager.OwnerForm
	
	$reportSlot.add_RenderCompleted({ displayGeneratedReport })
	$ownerForm.add_load({ $reportSlot.Prepare() })
	$ownerForm.ShowDialog()
}

###############################################################
#
# Opens up report designer where users can create a new report.
#
###############################################################
function New-Report($query, $connectionString, [switch]$chart, [switch]$scaffold)
{
	#######################################################################
	# Helper function to init the variables we'll reuse inside STA call.
	# Need that because we  can't pass parameters into STA block, and to circumvent that we create environment variables and delete them before we return from the method.
	#######################################################################
	function initEnvironmentVariables($query, $connectionString, [switch]$chart, [switch]$scaffold)
	{
			$env:SharpShooterReportXmlTemplate = '<?xml version="1.0" encoding="utf-8" standalone="yes"?>
									<root type="PerpetuumSoft.Reporting.DOM.Document" Name="document1" version="2" GridStep="59.055118560791016" IsTemplate="true" InvalidRenderLength="ThrowException" DocumentGuid="{{0}}">
										  <DataSources type="PerpetuumSoft.Reporting.Data.DocumentDataSourceCollection">
												<Item type="PerpetuumSoft.Reporting.Data.SqlDataSource" Name="{{1}}" ConnectionString="{{2}}" SelectQuery="{{3}}" />
										  </DataSources>
										  <Pages type="PerpetuumSoft.Reporting.DOM.PageCollection">
												<Item type="PerpetuumSoft.Reporting.DOM.Page" Name="page1" Location="0;0" Size="{0};3507.8740157480315" Margins="{1}; {1}; {1}; {1}">
													  <Controls type="PerpetuumSoft.Reporting.DOM.ReportControlCollection">
														{{4}}
													  </Controls>                                   
												</Item>
										  </Pages>
									</root>'
			if ($query -ne $null)            { $env:SharpShooterReportQuery = $query }
			if ($connectionString -ne $null) { $env:SharpShooterReportConnectionString = $connectionString }
			if($chart.isPresent)             { 
				$env:SharpShooterReportCreateChart = $true 
				$env:SharpShooterReportChartTemplate = '<Item type="PerpetuumSoft.Reporting.MSChart.MicrosoftChart" DataSource="{0}" Name="{1}" Size="1535.43310546875;767.716552734375" Location="531.49606704711914;236.22047424316406">
										<ChartAreas type="System.Windows.Forms.DataVisualization.Charting.ChartAreaCollection">
											<Item type="PerpetuumSoft.Reporting.MSChart.ChartModel.ChartArea" Name="ChartArea1" BackImage="" />
										</ChartAreas>
									  </Item>'
			}                
			if($scaffold.isPresent)          { 
				$env:SharpShooterReportScaffold = $true 
				$env:SharpShooterReportHeaderTemplate = '<Item type="PerpetuumSoft.Reporting.DOM.Header" Name="header1" Size="{0};118.11023712158203" Location="0;59.055118560791016">
										<DataBindings type="PerpetuumSoft.Reporting.DOM.ReportDataBindingCollection" />
										<Aggregates type="PerpetuumSoft.Reporting.DOM.AggregateCollection"/>
										<Controls type="PerpetuumSoft.Reporting.DOM.ReportControlCollection">
											{{0}}
										</Controls>
									</Item>'
									
				$env:SharpShooterReportHeaderItemTemplate = '<Item type="PerpetuumSoft.Reporting.DOM.TextBox" Name="txtHeader{0}" Text="{0}" Size="{1};118.11023712158203" Location="{2};0">
											<Font type="PerpetuumSoft.Framework.Drawing.FontDescriptor" FamilyName="Arial" Bold="On" Size="12"/>
											<DataBindings type="PerpetuumSoft.Reporting.DOM.ReportDataBindingCollection"/>
										   </Item>'
									
				$env:SharpShooterReportDetailTemplate = '<Item type="PerpetuumSoft.Reporting.DOM.Detail" Name="detail1" Size="{0};118.11023712158203" Location="0;236.22047424316406">
									<DataBindings type="PerpetuumSoft.Reporting.DOM.ReportDataBindingCollection"/>
										<Aggregates type="PerpetuumSoft.Reporting.DOM.AggregateCollection"/>
										<Controls type="PerpetuumSoft.Reporting.DOM.ReportControlCollection">
											{{0}}
										</Controls>
									</Item>'
									
				$env:SharpShooterReportDetailItemTemplate = '<Item type="PerpetuumSoft.Reporting.DOM.TextBox" Name="txt{0}" Size="{1};118.11023712158203" Location="{2};0">
											<Font type="PerpetuumSoft.Framework.Drawing.FontDescriptor" FamilyName="Arial" Bold="Off" Size="12"/>
											<DataBindings type="PerpetuumSoft.Reporting.DOM.ReportDataBindingCollection">
												<Item type="PerpetuumSoft.Reporting.DOM.ReportDataBinding" Expression="GetData(&quot;PowershellDataSource.{0}&quot;)" PropertyName="Value"/>
											</DataBindings>
										   </Item>'
									
				$env:SharpShooterReportDataBandTemplate = '<Item type="PerpetuumSoft.Reporting.DOM.DataBand" Name="dataBand1" Size="{0};531.49606704711914" DataSource="{1}" Location="0;177.16535568237305" ColumnsGap="0">
										<Totals type="PerpetuumSoft.Reporting.DOM.DataBandTotalCollection"/>
										<Sort type="PerpetuumSoft.Reporting.DOM.DataBandSortCollection"/>
										<Controls type="PerpetuumSoft.Reporting.DOM.ReportControlCollection">
											{{0}}
											{{1}}
										</Controls>
									 </Item>' 
			}                        
	}
	
	try {
	
		initEnvironmentVariables -query:$query -connectionString:$connectionString -chart:$chart -scaffold:$scaffold
		
		##########################
		# Start of STA block.
		# Need that because we start off a WinForms app (Report Designer). 
		##########################
		powershell -noprofile -sta -command {
	  
			#######################################################################
			# Helper function to create XML representing the report layout.
			#######################################################################
			function createXml($dataSourceName, $connectionString, $query, $createChart, $dataTable)
			{
				$result = $null
				
				#if connection string not set, assume localhost and trusted connection
				if ($connectionString -eq $null) { $connectionString = "Server={0};Database=master;Trusted_Connection=True;" -f [Environment]::MachineName }
				if ($query.EndsWith(".sql")) { $query = [System.IO.File]::ReadAllText($query)  }
				
				$pageWidth = 2480
				$marginWidth = 118
								
				$xmlTemplate = ($env:SharpShooterReportXmlTemplate.Trim() -f $pageWidth, $marginWidth )
				
				if ($createChart -eq $true) {
					$chart = $env:SharpShooterReportChartTemplate.Trim() -f $dataSourceName, "powershellChart"
					$result = $xmlTemplate.Trim() -f [Guid]::NewGuid(), $dataSourceName, $connectionString, $query, $chart
				}
				elseif ($scaffold -eq $true) {
					
					$dataBandTemplate = ($env:SharpShooterReportDataBandTemplate.Trim() -f $pageWidth, $dataSourceName)
					$headerTemplate = ($env:SharpShooterReportHeaderTemplate.Trim() -f $pageWidth)
					$headerItemTemplate = $env:SharpShooterReportHeaderItemTemplate
					$detailTemplate = ($env:SharpShooterReportDetailTemplate.Trim() -f $pageWidth)
					$detailItemTemplate = $env:SharpShooterReportDetailItemTemplate
										   
					$adapter = new-object "System.Data.SqlClient.SqlDataAdapter" ($query, $connectionString) 
					$dataset = new-object "System.Data.DataSet" "TemporaryPowershellDataSet"
					$adapter.Fill($dataset)
					$table = $dataset.Tables[0]                                          
										   
					$columnCount = $table.Columns.Count
					$availablePageWidth = $pageWidth - 2*$marginWidth
					$columnWidth = $availablePageWidth/$columnCount
					
					$headerItems = ""
					$detailtems = ""
					$columnPosition = 1
					foreach ($i in $table.Columns) {
						$horizontalLocation = $marginWidth + (($columnPosition - 1)/$columnCount)*$availablePageWidth
						$headerItems = $headerItems + "`n" + ($headerItemTemplate.Trim() -f $i, $columnWidth, $horizontalLocation)
						$detailItems = $detailItems + "`n" + ($detailItemTemplate.Trim() -f $i, $columnWidth, $horizontalLocation)
						$columnPosition = $columnPosition + 1
					}
					$header = $headerTemplate.Trim() -f $headerItems
					$details = $detailTemplate.Trim() -f $detailItems
										
					$result = $xmlTemplate.Trim() -f [Guid]::NewGuid(), $dataSourceName, $connectionString, $query, ($dataBandTemplate.Trim() -f $header, $details)
				}
				else {
					$result = $xmlTemplate.Trim() -f [Guid]::NewGuid(), $dataSourceName, $connectionString, $query, '' 
				}   
					   
				return $result
			}
		
			#######################################################################
			# Helper function to write the report layout XML to a file.
			#######################################################################
			function createDefaultReportFile($fileName, $dataSourceName, $connectionString, $query, $createChart, $scaffold)
			{
				try {
					$xml = createXml -dataSourceName:$dataSourceName -connectionString:$connectionString -query:$query -createChart:$createChart -scaffold:$scaffold
					if ($scaffold -eq $true) {
						$xml = $xml[1] #unfortunately, powershell also returns the result of "$dataset.Tables[0]" call (!) along with the xml we need
					}
				
					$stream = [System.IO.StreamWriter] $fileName
					$stream.WriteLine($xml)
				}
				finally {
					$stream.Close()
				}
			}
			
			###########################################################################
			# Helper function to load all the necessary assemblies. UNFORTUNATELY, HAVE TO DUPLICATE IT HERE.
			###########################################################################
			function loadAssemblies()
			{
				$programFiles = ${env:ProgramFiles}
				if ([IntPtr]::Size -eq 8) { $programFiles = ${env:ProgramFiles(x86)} } 
				$binaries = join-path $programFiles "Perpetuum Software\Net ModelKit Suite\Bin"
				if (!(test-path $binaries)) {
					#maybe it's RSS6.0 or later
					$binaries = join-path $programFiles "Perpetuum Software\SharpShooter Collection\Bin"
				}
				[System.Reflection.Assembly]::LoadFrom("$binaries\PerpetuumSoft.Reporting.dll") | out-null
				if ([System.IO.File]::ReadAllText($reportFile).Contains("Reporting.MSChart.MicrosoftChart")) {
					[System.Reflection.Assembly]::LoadFrom("$binaries\PerpetuumSoft.Reporting.MSChart.dll") | out-null 
				}
				[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | out-null    
			}
			
		
			#######################################################################
			# Main part of the STA block
			#######################################################################
			$reportFile = "{0}.rst" -f ([Guid]::NewGuid().ToString().Split('-')[-1])
			$reportFile = [System.IO.Path]::GetFullPath($reportFile)
			
			if ([System.IO.File]::Exists($reportFile)) {
				write-host -ForegroundColor Red "`nCannot overwrite the already existing $reportFile`n"
				return
			}
			
			write-host -ForegroundColor DarkGray "Generating a temp report at $reportFile"
			createDefaultReportFile -fileName:$reportFile -dataSourceName:"PowershellDataSource" -connectionString:$env:SharpShooterReportConnectionString -query:$env:SharpShooterReportQuery -createChart:$env:SharpShooterReportCreateChart -scaffold:$env:SharpShooterReportScaffold
						
			loadAssemblies
			$reportSlot = new-object PerpetuumSoft.Reporting.Components.FileReportSlot
			$reportSlot.FilePath = $reportFile

			$reportManager = new-object PerpetuumSoft.Reporting.Components.ReportManager
			$reportManager.DataSources = new-object PerpetuumSoft.Reporting.Components.ObjectPointerCollection
			$reportManager.Reports.Add([PerpetuumSoft.Reporting.Components.ReportSlot]$reportSlot) | out-null
			
			$reportSlot.DesignTemplate()   
		}
		##########################
		# End of STA block
		##########################
	}
	finally {        
		if ($env:SharpShooterReportXmlTemplate -ne $null)        { Remove-Item Env:\SharpShooterReportXmlTemplate }
		if ($env:SharpShooterReportQuery -ne $null)              { Remove-Item Env:\SharpShooterReportQuery }
		if ($env:SharpShooterReportConnectionString -ne $null)   { Remove-Item Env:\SharpShooterReportConnectionString }
		
		if ($env:SharpShooterReportCreateChart -ne $null)        { Remove-Item Env:\SharpShooterReportCreateChart }
		if ($env:SharpShooterReportChartTemplate -ne $null)      { Remove-Item Env:\SharpShooterReportChartTemplate }
		
		if ($env:SharpShooterReportScaffold -ne $null)           { Remove-Item Env:\SharpShooterReportScaffold }    
		if ($env:SharpShooterReportHeaderTemplate -ne $null)     { Remove-Item Env:\SharpShooterReportHeaderTemplate } 
		if ($env:SharpShooterReportHeaderItemTemplate -ne $null) { Remove-Item Env:\SharpShooterReportHeaderItemTemplate } 
		   
		if ($env:SharpShooterReportDetailTemplate -ne $null)     { Remove-Item Env:\SharpShooterReportDetailTemplate }    
		if ($env:SharpShooterReportDetailItemTemplate -ne $null) { Remove-Item Env:\SharpShooterReportDetailItemTemplate }    
		if ($env:SharpShooterReportDataBandTemplate -ne $null)   { Remove-Item Env:\SharpShooterReportDataBandTemplate }    
	}
}
