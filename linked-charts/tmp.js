<code>...</code>

<code>var heatmap = d3.heatmapChart()</code>
<code>  .showLegend( false )</code>
<code>  .margin( {top: 100, left: 100, right: 10, bottom: 10} )</code>
<code>  ...</code>
<code>  .place( "#heatmap" );</code>

<code>var heatmapSlider = d3.sigmoidColorSlider()</code>
<code>	.set_margin( {left: 100} )</code>
<code>	.straightColorScale( heatmap.colourScale )</code>
<code>	.on_change(function(){</code>
<code>		heatmap.updateCellColour();</code>
<code>	})</code>
<code>  .place( "#heatmap" );</code>

<code>heatmap.colour( function( val ){</code>
<code>	return heatmapSlider.colourScale( val );</code>
<code>} );</code>
<code>...</code>

<code>var scatterplot = d3.scatterChart()</code>
<code>  .width( 300 )</code>
<code>  .set_margin( {bottom: 20} )</code>
<code>  .showLegend( false )</code>
<code>  ...</code>
<code>  .on_click( function( k ) {</code>
<code>    scatterplot.svg.selectAll( ".clicked" )</code>
<code>    	.classed( "clicked", false );</code>
<code>    d3.select( this ).classed( "clicked", true );</code>
<code>    selCellLine = k;</code>
<code>    curveFit.update();</code>
<code>  });</code>
<code>d3.lineChart( "line", scatterplot )</code>
<code>	...</code>
<code>  .place( "#scatterplot" );</code>

<code>var layer = scatterplot.get_layer( "layer0" );</code>

<code>var scatterSlider = d3.sigmoidColorSlider()</code>
<code>	.width( 300 )</code>
<code>	.height( 110 )</code>
<code>	.set_margin( {top: 50} )</code>
<code>	.title( "Total curvefitting error" )</code>
<code>	.straightColorScale( layer.colourScale )</code>
<code>	.on_change( function(){</code>
<code>		layer.updatePointStyle();</code>
<code>	} )</code>
<code>  .place( "#scatterplot" );</code>

<code>layer.colour(function( id ){</code>
<code>	return scatterSlider.colourScale( layer.get_colourValue( id ) );</code>
<code>});</code>

<code>var curveFit = d3.scatterChart( "points" )</code>
<code>	...</code>
<code>  .place( "#scatterplot" );</code>