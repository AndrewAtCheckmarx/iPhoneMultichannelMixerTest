#!/bin/sh
USERNAME="andrew.thompson@checkmarx.com"
PASS="Barn4Max-"
CX_HOST="https://cxprivatecloud.checkmarx.net"
PRESET="All"
CX_TEAM=CxServer\\SP\EMEA\\Checkmarx.com-UK


# ###############################################
CX_CONSOLE_PATH=$BUDDYBUILD_WORKSPACE/CxConsole
CX_BUDDY_BUILD_PATH=$BUDDYBUILD_WORKSPACE

# locate xsltproc
XSLT_EXE=/usr/share/bash-completion/completions/xsltproc
# ##############################################


# whitelist input - using $* could introduce command injection!!

HIGH_VULNERABILITY_THRESHOLD=0
MEDIUM_VULNERABILITY_THRESHOLD=0

while getopts "p:n:t:h:m:" arg; do
	case $arg in
		p)
			echo "Profile: " $OPTARG
			PROFILE=$OPTARG
			;;
		n)
			echo "ProjectName: " $OPTARG
			PROJECT=$OPTARG
			;;
		t)
			echo "Team: " $OPTARG
			CX_TEAM=$OPTARG
			;;
			
		r)
			echo "OsaReportPDF: " 
			OSA_REPORT="-OsaReportPDF"
			;;
			
		e)
			echo "EnableOSA: " 
			ENABLE_OSA="-EnableOsa"
			;;
		h)
			echo "High Threshold: " $OPTARG
			HIGH_VULNERABILITY_THRESHOLD=$OPTARG
			;;
		m)
			echo "Medium Threshold: " $OPTARG
			MEDIUM_VULNERABILITY_THRESHOLD=$OPTARG
			;;
	esac
done

    JOB_NAME=$BUDDYBUILD_BUILD_ID


echo BUDDYBUILD_WORKSPACE $BUDDYBUILD_WORKSPACE
CX_RESULTS_XML=$BUDDYBUILD_WORKSPACE/${JOB_NAME}/report/${JOB_NAME}_CxResults.xml
CX_RESULTS_PDF=$BUDDYBUILD_WORKSPACE/${JOB_NAME}/report/${JOB_NAME}_CxResults.pdf
CX_RESULTS_HTML=$BUDDYBUILD_WORKSPACE/${JOB_NAME}/report/${JOB_NAME}_CxResults.html
CX_LOG=$BUDDYBUILD_WORKSPACE/$JOB_NAME/logs

CX_CONSOLE_EXE=$CX_CONSOLE_PATH/runCxConsole.sh
XSLT_HTML_OUTPUT=$CX_BUDDY_BUILD_PATH/CxResult.xslt
XSLT_VULN_COUNT=$CX_BUDDY_BUILD_PATH/CxHigh.xslt

echo $CX_RESULTS_XML
echo $CX_RESULTS_PDF
echo $CX_RESULTS_HTML
echo $CX_CONSOLE_EXE

chmod +x $CX_CONSOLE_EXE

mkdir  $BUDDYBUILD_WORKSPACE/$JOB_NAME
mkdir  $BUDDYBUILD_WORKSPACE/$JOB_NAME/report

echo XML Report $CX_RESULTS_XML

# Scan the workspace, saving the results in xml and pdf
echo $CX_CONSOLE_EXE Scan -CxServer $CX_HOST -CxUser $USERNAME -CxPassword $PASS -v -LocationType folder -locationPath $BUDDYBUILD_WORKSPACE -reportPDF "$CX_RESULTS_PDF" -reportXML "$CX_RESULTS_XML" -ProjectName $CX_TEAM$PROJECT -Profile $PROFILE

$CX_CONSOLE_EXE Scan -CxServer $CX_HOST -CxUser $USERNAME -CxPassword $PASS -v -LocationType folder -locationPath $BUDDYBUILD_WORKSPACE -reportPDF "$CX_RESULTS_PDF" -reportXML "$CX_RESULTS_XML" -ProjectName $CX_TEAM$PROJECT -Profile $PROFILE 

[ -f $CX_RESULTS_XML ] && echo found || echo not found

echo xml $CX_RESULTS_XML
echo xslt $XSLT_EXE 



# Process the xml results if they exist
# [ -f $CX_RESULTS_XML ]
if [ -f $CX_RESULTS_XML -a -x $XSLT_EXE ]
then
    echo found xml
    echo $XSLT_EXE  -o "$CX_RESULTS_HTML" "$XSLT_HTML_OUTPUT" "$CX_RESULTS_XML" 
    $XSLT_EXE  -o "$CX_RESULTS_HTML" "$XSLT_HTML_OUTPUT" "$CX_RESULTS_XML" 


    RES=`$XSLT_EXE "$XSLT_VULN_COUNT" "$CX_RESULTS_XML"`
    
    HIGH=`echo "$RES"   | awk '/High/ { print $2; }'`
    MEDIUM=`echo "$RES" | awk '/Medium/ { print $2; }'`
    if [ $HIGH -gt $HIGH_VULNERABILITY_THRESHOLD -o $MEDIUM -gt $MEDIUM_VULNERABILITY_THRESHOLD ]
    then
        echo "Threshold exceeded"
		exit 1
    fi
else
	echo No XML ??
fi




