package My::Map::Package;
  use base AI::Pathfinding::AStar;

  # Methods required by AI::Pathfinding::AStar
  sub getSurrounding { ... }

  package main;
  use My::Map::Package;

  my $map = My::Map::Package->new or die "No map for you!";
  my $path = $map->findPath($start, $target);
  print join(', ', @$path), "\n";
  
  #Or you can do it incrementally, say 3 nodes at a time
  my $state = $map->findPathIncr($start, $target, undef, 3);
  while ($state->{path}->[-1] ne $target) {
          print join(', ', @{$state->{path}}), "\n";
          $state = $map->findPathIncr($start, $target, $state, 3);
  }
  print "Completed Path: ", join(', ', @{$state->{path}}), "\n";
