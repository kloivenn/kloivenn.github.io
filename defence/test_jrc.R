library(jrc)

openPage(startPage = "test_igv.html")
callFunction("browser.zoomIn")
callFunction("browser.zoomOut")

callFunction("browser.search", list("EGFR"));
callFunction("browser.zoomIn")

sendCommand("jrc.sendData('loci', browser.currentLoci())")

allowVariables('loci')
sendCommand("jrc.sendData('loci', browser.currentLoci())")
