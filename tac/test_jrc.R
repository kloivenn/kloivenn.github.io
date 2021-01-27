library(jrc)

openPage(startPage = "test_jrc.html")

callFunction("moveCircle", list(200, 400))
sendCommand("moveCircle(200, 300)")

sendHTML("<p>Let's add some <b>text</b>!</p>")

#jrc.sendData('coord', [c.cx.baseVal.value, c.cy.baseVal.value]);

openPage(startPage = "test_jrc.html", allowedVariables = "coord")
