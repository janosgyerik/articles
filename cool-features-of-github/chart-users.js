// Paste this code on this page:
// https://code.google.com/apis/ajax/playground/?type=visualization#area_chart
function drawVisualization() {
  // Some raw data
  var data = google.visualization.arrayToDataTable([
    ['Year',   'Users' ],
    ['2008',    0 ],
    ['2009',    42000 ],
    ['2010',    166000 ],
    ['2011',    510000 ],
    ['2012',    1200000 ],
    ['2013',    1900000 ]
  ]);

  // Create and draw the visualization.
  var ac = new google.visualization.AreaChart(document.getElementById('visualization'));
  ac.draw(data, {
    title : 'Users',
    isStacked: true,
    width: 800,
    height: 400
  });
}
​

