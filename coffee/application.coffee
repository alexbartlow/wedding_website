rsvp = window.angular.module("rsvp", [])

window.RsvpControl = ($scope, $http) ->
  $scope.last_name = ""
  $scope.possible_rows = []
  $scope.loading = false

  $scope.selected = null

  $scope.finished = ->
    $scope.accepted || $scope.rejected

  $scope.submitclicked = ->
    opts =
      method: 'GET',
      url: '/last_name',
      params:
        last_name: $scope.last_name
    $scope.loading = true
    $http(opts).success (data) ->
      _.each data, (invite) ->
        invite.attending ||= invite.invitees.slice(-1)[0]
      $scope.loading = false
      console.log(data)
      $scope.possible_rows = data
    
    return false

  $scope.accept = ->
    $scope.accepted = true
    opts =
      method: 'POST'
      url: '/accept'
      data: $scope.selected
    $http(opts).success ->

  $scope.reject = ->
    opts =
      method: 'POST'
      url: '/decline'
      data: $scope.selected
    $http(opts).success ->

    $scope.rejected = true

rsvp.controller RsvpControl, ['$scope', '$http']
