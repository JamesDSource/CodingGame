#macro CELLSIZE 32
grid_width = room_width div CELLSIZE;
grid_height = room_height div CELLSIZE;

global.mp_grid = mp_grid_create(0, 0, grid_width, grid_height, CELLSIZE, CELLSIZE); // mp grid
global.grid = ds_grid_create(grid_width, grid_height);