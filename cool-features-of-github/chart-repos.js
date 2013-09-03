// Paste this code on this page:
// https://code.google.com/apis/ajax/playground/?type=visualization#area_chart
function drawVisualization() {
  // Some raw data
  var data = google.visualization.arrayToDataTable([
    ['Year',   'Users' ],
    ['2008',    0 ],
    ['2009',    80000 ],
    ['2010',    484000 ],
    ['2011',    1300000 ],
    ['2012',    3400000 ],
    ['2013',    6500000 ]
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
