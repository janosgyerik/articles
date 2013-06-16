function drawVisualization() {
  // Some raw data (not necessarily accurate)
/*
- Jan 2008 -- 0
- Dec 2008 -- 42k users, 80k repos
- 2010 -- 166k users, 484k repos
- 2011 -- 510k users, 1.3m repos
- 2012 -- 1.2m users, 3.4m repos
- Aug 2012 -- 1.9m users, 6.5m repos
*/
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
