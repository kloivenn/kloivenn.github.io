<code>var heatmap = d3.heatmapChart()</code>
<code>  ...</code>
<code>  .title("Drug-drug correlation")</code>
<code>  .palette( function( val ) { return d3.interpolateRdBu( 1 - val ); } )</code>
<code>  .place( "#heatmap" );</code>
<code></code>
<code>...</code>
<code></code>
<code>var scatterplot = d3.scatterChart("Total curvefitting error")</code>
<code>  .width( 375 )</code>
<code>  ...</code>
<code>  .labelX(function() {return selDrugs[0]})</code>
<code>  .labelY(function() {return selDrugs[1]})</code>
<code>  .title("Average inhibition")</code>
<code>  .domainX([-10, 50])</code>
<code>  .domainY([-10, 50]);</code>
<code>d3.lineChart("line", scatterplot)</code>
<code>  ...</code>
<code>  .place( "#scatterplot" );</code>
<code></code>
<code>var curveFit = d3.scatterChart( "points" )</code>
<code>  .width( 375 )</code>
<code>  ...</code>
<code>  .title(function() {return selCellLine;})</code>
<code>  .labelX("Drug concentration")</code>
<code>  .labelY("Inhibition")</code>
<code>  .domainY([-25, 100])</code>
<code>  .ticksX(function() {</code>
<code>    var ticks = [d3.range(5), </code>
<code>      d3.range(5).map(function(e) {</code>
<code>        return inputData.RTG[selDrugs[0]][selCellLine].minConc * </code>
<code>                Math.pow(10, e)</code>
<code>      }),</code>
<code>      d3.range(5).map(function(e) {</code>
<code>        return inputData.RTG[selDrugs[1]][selCellLine].minConc * </code>
<code>                Math.pow(10, e)</code>
<code>      })];</code>
<code>    ticks.colour = ["blue", "red"];</code>
<code>    return ticks;</code>
<code>  });</code>
<code>curveFit.legend.add(function() {return [selDrugs, ["blue", "red"]];}, </code>
<code>                      "colour", "Drugs");  </code>
<code>d3.lineChart("lines", curveFit)</code>
<code>  ...</code>
<code>  .place( "#scatterplot" );</code>