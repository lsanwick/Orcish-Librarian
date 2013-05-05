(function(){

  var latestJobId = 0;

  Orcish.register('Queue', Orcish.extend({

    initialize: function() {
      this.waiting = [ ];
      this.runningJobId = 0;
    },

    addJob: function(automatic, callback) {
      this.waiting.push({ automatic: automatic, callback: callback });
      checkJobs(this);
    },

    finished: function(id) {
      if (this.runningJobId == id) {
        this.runningJobId = null;
      }
      checkJobs(this);
    }

  }))

  function checkJobs(self) {
    if (!self.runningJobId) {
      var job = self.waiting.shift();
      if (job) {
        var jobId = ++latestJobId;
        self.runningJobId = jobId;
        setTimeout(function() {
          job.callback(jobId);
          if (job.automatic) {
            self.finished(jobId)
          }
        }, 1);
      }
    }
  }

})()