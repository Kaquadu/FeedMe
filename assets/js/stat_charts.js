import Chart from 'chart.js';

const StatCharts = {
  run() {
    if (!$('#averagesChart').length) {return;}
    this.handleAveragesChart();
    this.handleDailyCaloriesChart();
    this.handleDailyMacroChart();
  },

  filterEmpty(value) {
    return value != ""
  },

  handleAveragesChart() {
    var ctx = $('#averagesChart');

    var average_values = ctx.data("averages").split(',').filter(this.filterEmpty)
    var desired_values = ctx.data("desired").split(',').filter(this.filterEmpty)

    var myChart = new Chart(ctx, {
      type: 'bar',
      data: {
          labels: ['Calories', 'Carbs', 'Fats', 'Proteins'],
          datasets: [
            {
              label: "Calculated",
              backgroundColor: 'rgba(255, 99, 132, 0.2)',
              data: average_values
            },
            {
              label: "Desired",
              backgroundColor: 'rgba(75, 192, 192, 0.2)',
              data: desired_values
            }
          ]
      },
      options: {
          scales: {
              yAxes: [{
                  ticks: {
                      beginAtZero: true
                  }
              }]
          }
      }
    });
  },

  handleDailyCaloriesChart() {
    var ctx = $('#dailyCaloriesChart');

    var day_values = ctx.data("day").split(',').filter(this.filterEmpty).reverse()
    var calories_values = ctx.data("calories").split(',').filter(this.filterEmpty).reverse()

    var myChart = new Chart(ctx, {
      type: 'bar',
      data: {
          labels: day_values,
          datasets: [
            {
              label: "Calories",
              backgroundColor: 'rgba(255, 99, 132, 0.2)',
              data: calories_values
            }
          ]
      },
      options: {
          scales: {
              yAxes: [{
                  ticks: {
                      beginAtZero: true
                  }
              }]
          }
      }
    });
  },
  
  handleDailyMacroChart() {
    var ctx = $('#dailyMacroChart');

    var day_values = ctx.data("day").split(',').filter(this.filterEmpty).reverse()
    var fats_values = ctx.data("fats").split(',').filter(this.filterEmpty).reverse()
    var carbs_values = ctx.data("carbs").split(',').filter(this.filterEmpty).reverse()
    var proteins_values = ctx.data("proteins").split(',').filter(this.filterEmpty).reverse()

    var myChart = new Chart(ctx, {
      type: 'bar',
      data: {
          labels: day_values,
          datasets: [
            {
              label: "Fats",
              backgroundColor: 'rgba(75, 192, 192, 0.2)',
              data: fats_values
            },
            {
              label: "Carbs",
              backgroundColor: 'rgba(255, 99, 00, 0.2)',
              data: carbs_values
            },
            {
              label: "Proteins",
              backgroundColor: 'rgba(75, 255, 192, 0.2)',
              data: proteins_values
            }
          ]
      },
      options: {
          scales: {
              yAxes: [{
                  ticks: {
                      beginAtZero: true
                  }
              }]
          }
      }
    });
  }
}

export default StatCharts;
