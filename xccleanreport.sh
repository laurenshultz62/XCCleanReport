#!/bin/sh

basePath=${PWD}
path=""
body=""
testFailCount=0

workspace="Final Mile.xcworkspace"
scheme="Final Mile (QA)"
iphone="iPhone XR"
os="12.1"
resultsDirectory="TestResults"

echo "Starting XCCleanReport..."

function runTests() {
    echo "Running Tests..."
    xcodebuild test -workspace "$workspace" -scheme "$scheme" -destination 'platform=iOS Simulator,name=iPhone XR,OS=12.1' -resultBundlePath $resultsDirectory

    path=$basePath"/"$resultsDirectory
    buildReport
}

function buildReport() {
echo "Generating XCCleanReport..."
    tempPath=$path"/Info.plist"

    testFailCount=`/usr/libexec/PlistBuddy -c "Print TestsFailedCount" ${tempPath}`
    for (( idx=0; idx<$testFailCount; idx++)); do
        TestCase=`/usr/libexec/PlistBuddy -c "Print TestFailureSummaries:${idx}:TestCase" ${tempPath}`
        Message=`/usr/libexec/PlistBuddy -c "Print TestFailureSummaries:${idx}:Message" ${tempPath}`

        TCNameP1=$(echo "$TestCase" | cut -d'(' -f1 | cut -d'.' -f1)
        TCNameP2=$(echo "$TestCase" | cut -d'(' -f1 | cut -d'.' -f2)
        ScreenshotPath=$path"/Attachments/$TCNameP1$TCNameP2*.png"
# Uncomment to append all found attatchments for test case to report
#        tied_screenshots=$(echo $ScreenshotPath)
#        IFS=' ' read -ra split_screenshots <<< "$tied_screenshots"
#        screenshots=""
#        for screenshot in "${split_screenshots[@]}"; do
#            newShot="<img class=\"TestScreenshot\" src=\""$screenshot"\">"
#            screenshots=$screenshots$newShot
#        done
# Comment 30 & 31 out to append all found attatchments for test case to report
        screenshots=$(echo $ScreenshotPath | cut -d' ' -f1)
        screenshots="<img class=\"TestScreenshot\" src=\""$screenshots"\">"

        addTestFailToList "$TestCase" "$Message" "$screenshots"
    done

#Generate Files
    htmlPath=$path"/index.html"
    cssPath=$path"/style.css"
    generateHtml > $htmlPath
    generateCss > $cssPath
    echo "File create at "$htmlPath
}

function generateCss() {
cat << _EOF_
.FailedTest {
border-style: solid;
border-bottom: 10px;
padding: 10px;
border-bottom-color: black;
}

.FailedTest .TestCaseTitle {
background-color: rgb(204, 51, 0);
}

.PassedTest {
background-color: green;
border-bottom: 5px;
border-bottom-color: black;
}

.TestScreenshot {
height: 300px;
}

.TestName {
font-weight: bold;
}

.TestCaseTitle {
padding: 5px;
border-style: outset;
}

.TestCaseContent {

}
_EOF_
}

function generateHtml() {
cat << _EOF_
<!doctype html>
<html>
<head>
<title>XC Clean Report</title>
<link rel="stylesheet" href="style.css">
</head>

<body>
<h1>XC Clean Report</h1>
<h2>Failed Tests ($testFailCount):</h2>
$body
</body>

</html>
_EOF_
}

function addTestFailToList() {
	newTest="<div class=\"FailedTest\">"
    newTest=$newTest"<div class=\"TestCaseTitle\">"
#name
    newTest=$newTest"<p class=\"TestName\">"$1"</p>"
    newTest=$newTest"</div>"
    newTest=$newTest"<div class=\"TestCaseContent\">"
#message
    newTest=$newTest"<p class=\"TestMessage\">"$2"</p>"
#screenshot
#newTest=$newTest"<img class=\"TestScreenshot\" src=\""$3"\">"
    newTest=$newTest$3
    newTest=$newTest"</div>"
#end of div
	newTest=$newTest"</div>"
	body=$body$newTest
}

function buildImage() {
    echo "<img class=\"TestScreenshot\" src=\""$1"\">"
}

function addTestPassToList() {
    newTest="<div class=\"PassedTest\">"
#name
    newTest=$newTest"<p class=\"TestName\">"$1"</p>"
#message
    newTest=$newTest"<p class=\"TestMessage\">"$2"</p>"
    newTest=$newTest"</div>"
    body=$body$newTest
}

while getopts ":r:f:w:s:i:o:d:t" opt; do
	case "$opt" in
        w) workspace="$OPTARG" >&2 ;;
        s) scheme="$OPTARG" >&2 ;;
        i) iphone="$OPTARG" >&2 ;;
        o) os="$OPTARG" >&2 ;;
        d) resultsDirectory="$OPTARG" >&2 ;;
        t) runTests ;;
		r) path=$basePath"/$OPTARG" >&2
		  buildReport ;;
        f) path="$OPTARG" >&2
           buildReport ;;
		*) echo "Command Unkown" ;;
	esac
done
