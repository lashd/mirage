#TODO write me, functionality for extending mirage
Feature: Mirage is written using the Ramaze web framework. Should you want to text extend, simply require the 'core' and
  make your modifications.

Scenario: Exending Mirage
  Given a file 'mirage_entension.rb' that contains:
  """

  """
  When I run 'ruby mirage_entension.rb'
  And goto 'http://localhost:7000/mirage/mynewendpoint'
  Then a 200 hundred should be returned