(function(){

  var latestJobId = 0;

  Orcish.register('Queue', Orcish.extend({

    initialize: function() {
      this.waiting = [ ];
      this.runningJobId = 0;
    },

    addJob: function(callback) {
      this.waiting.push(callback);
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
        self.runningJobId = ++latestJobId;
        job(self.runningJobId);
      }
    }
  }

})()