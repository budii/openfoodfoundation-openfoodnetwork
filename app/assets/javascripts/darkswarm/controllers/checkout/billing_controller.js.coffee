angular.module('Darkswarm').controller "BillingCtrl", ($scope, $timeout, $controller) ->
  angular.extend this, $controller('FieldsetMixin', {$scope: $scope})

  $scope.name = "billing"
  $scope.nextPanel = "shipping"

  $scope.summary = ->
    [$scope.order.bill_address.address1,
    $scope.order.bill_address.city,
    $scope.order.bill_address.zipcode]

  $timeout $scope.onTimeout
