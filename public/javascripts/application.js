(function() {
  var rsvp;

  rsvp = window.angular.module("rsvp", []);

  window.RsvpControl = function($scope, $http) {
    $scope.last_name = "";
    $scope.possible_rows = [];
    $scope.loading = false;
    $scope.selected = null;
    $scope.finished = function() {
      return $scope.accepted || $scope.rejected;
    };
    $scope.submitclicked = function() {
      var opts;
      opts = {
        method: 'GET',
        url: '/last_name',
        params: {
          last_name: $scope.last_name
        }
      };
      $scope.loading = true;
      $http(opts).success(function(data) {
        _.each(data, function(invite) {
          return invite.attending || (invite.attending = invite.invitees.slice(-1)[0]);
        });
        $scope.loading = false;
        console.log(data);
        return $scope.possible_rows = data;
      });
      return false;
    };
    $scope.accept = function() {
      var opts;
      $scope.accepted = true;
      opts = {
        method: 'POST',
        url: '/accept',
        data: $scope.selected
      };
      return $http(opts).success(function() {});
    };
    return $scope.reject = function() {
      var opts;
      opts = {
        method: 'POST',
        url: '/decline',
        data: $scope.selected
      };
      $http(opts).success(function() {});
      return $scope.rejected = true;
    };
  };

  rsvp.controller(RsvpControl, ['$scope', '$http']);

}).call(this);
