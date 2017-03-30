<code>var heatmap = lc.heatmapChart()</code>
<code>  .rowIds( drugs )</code>
<code>  .colIds( cellLines )</code>
<code>  .value( function( rowId, colId ) {  </code>
<code>    return [inputData.RTG[rowId][colId].avInh, </code>
<code>            inputData.CTX[rowId][colId].avInh];</code>
<code>   })</code>
<code>	...</code>
<code>  .place( "#heatmap" );</code>

<code>var RTGSlider = lc.sigmoidColorSlider()</code>
<code>  .straightColorScale( </code>
<code>    d3.scaleLinear()</code>
<code>      .range( [ "black", "rgb(0, 255, 0)" ] )</code>
<code>      .domain([0, 50]) </code>
<code>  )</code>
<code>  .on_change(function(){</code>
<code>    heatmap.updateCellColour();</code>
<code>	})</code>
<code>  ...</code>
<code>  .place( "#heatmap" );</code>

<code>heatmap.colour( function( val ){</code>
<code>  return "rgb(" + Math.round(CTXSlider.the_sigmoid(val[1]) * 255) + ", " </code>
<code>             + Math.round(RTGSlider.the_sigmoid(val[0]) * 255) + ", 0)";</code>
<code>} )</code>
<code>  .updateCellColour();</code>