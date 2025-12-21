/// CampusNav - Mock Map Data
///
/// Mock data for testing and demo purposes.
/// Contains sample building, floor, and navigation graph data.

import '../models/building_model.dart';
import '../models/location_model.dart';
import '../models/node_model.dart';

// =============================================================================
// MOCK BUILDINGS
// =============================================================================

final mockBuildings = [
  BuildingModel(
    id: 'main_building',
    name: 'Main Academic Block',
    description: 'Central academic building with classrooms and labs',
    floors: [
      FloorModel(
        id: 'main_floor_0',
        name: 'Ground Floor',
        level: 0,
        mapImagePath: 'assets/maps/main_floor_0.png',
        width: 800,
        height: 600,
        pixelsPerMeter: 10.0,
      ),
      FloorModel(
        id: 'main_floor_1',
        name: 'First Floor',
        level: 1,
        mapImagePath: 'assets/maps/main_floor_1.png',
        width: 800,
        height: 600,
        pixelsPerMeter: 10.0,
      ),
    ],
  ),
  BuildingModel(
    id: 'library',
    name: 'Central Library',
    description: 'Main campus library',
    floors: [
      FloorModel(
        id: 'lib_floor_0',
        name: 'Ground Floor',
        level: 0,
        mapImagePath: 'assets/maps/lib_floor_0.png',
        width: 600,
        height: 400,
        pixelsPerMeter: 10.0,
      ),
    ],
  ),
];

// =============================================================================
// MOCK LOCATIONS
// =============================================================================

final mockLocations = [
  LocationModel(
    id: 'loc_entrance',
    name: 'Main Entrance',
    buildingId: 'main_building',
    floorId: 'main_floor_0',
    x: 100,
    y: 300,
    category: 'entrance',
    tags: ['entry', 'reception'],
  ),
  LocationModel(
    id: 'loc_room101',
    name: 'Room 101 - Computer Lab',
    buildingId: 'main_building',
    floorId: 'main_floor_0',
    x: 300,
    y: 200,
    category: 'lab',
    tags: ['computer', 'lab', 'CS'],
  ),
  LocationModel(
    id: 'loc_room102',
    name: 'Room 102 - Lecture Hall A',
    buildingId: 'main_building',
    floorId: 'main_floor_0',
    x: 500,
    y: 200,
    category: 'classroom',
    tags: ['lecture', 'hall'],
  ),
  LocationModel(
    id: 'loc_cafeteria',
    name: 'Cafeteria',
    buildingId: 'main_building',
    floorId: 'main_floor_0',
    x: 700,
    y: 400,
    category: 'food',
    tags: ['food', 'cafe', 'canteen'],
  ),
  LocationModel(
    id: 'loc_hod_office',
    name: 'HOD Office - Computer Science',
    buildingId: 'main_building',
    floorId: 'main_floor_1',
    x: 200,
    y: 150,
    category: 'office',
    tags: ['office', 'HOD', 'CS', 'computer science'],
  ),
  LocationModel(
    id: 'loc_restroom_m',
    name: 'Restroom (Men)',
    buildingId: 'main_building',
    floorId: 'main_floor_0',
    x: 400,
    y: 550,
    category: 'restroom',
    isAccessible: true,
  ),
  LocationModel(
    id: 'loc_library_entrance',
    name: 'Library Entrance',
    buildingId: 'library',
    floorId: 'lib_floor_0',
    x: 50,
    y: 200,
    category: 'entrance',
  ),
];

// =============================================================================
// MOCK NODES (Navigation Graph)
// =============================================================================

final mockNodes = [
  // Main building ground floor nodes
  NodeModel(
    id: 'node_entrance',
    x: 100,
    y: 300,
    floorId: 'main_floor_0',
    locationId: 'loc_entrance',
    connectedNodeIds: ['node_corridor_1'],
  ),
  NodeModel(
    id: 'node_corridor_1',
    x: 200,
    y: 300,
    floorId: 'main_floor_0',
    connectedNodeIds: ['node_entrance', 'node_corridor_2', 'node_room101_door'],
  ),
  NodeModel(
    id: 'node_room101_door',
    x: 300,
    y: 250,
    floorId: 'main_floor_0',
    connectedNodeIds: ['node_corridor_1', 'node_room101'],
  ),
  NodeModel(
    id: 'node_room101',
    x: 300,
    y: 200,
    floorId: 'main_floor_0',
    locationId: 'loc_room101',
    connectedNodeIds: ['node_room101_door'],
  ),
  NodeModel(
    id: 'node_corridor_2',
    x: 400,
    y: 300,
    floorId: 'main_floor_0',
    connectedNodeIds: ['node_corridor_1', 'node_corridor_3', 'node_stairs'],
  ),
  NodeModel(
    id: 'node_stairs',
    x: 400,
    y: 350,
    floorId: 'main_floor_0',
    isStairs: true,
    connectedNodeIds: ['node_corridor_2', 'node_stairs_f1'],
  ),
  NodeModel(
    id: 'node_corridor_3',
    x: 500,
    y: 300,
    floorId: 'main_floor_0',
    connectedNodeIds: ['node_corridor_2', 'node_room102'],
  ),
  NodeModel(
    id: 'node_room102',
    x: 500,
    y: 200,
    floorId: 'main_floor_0',
    locationId: 'loc_room102',
    connectedNodeIds: ['node_corridor_3'],
  ),
  // First floor
  NodeModel(
    id: 'node_stairs_f1',
    x: 400,
    y: 350,
    floorId: 'main_floor_1',
    isStairs: true,
    connectedNodeIds: ['node_stairs', 'node_corridor_f1_1'],
  ),
  NodeModel(
    id: 'node_corridor_f1_1',
    x: 300,
    y: 300,
    floorId: 'main_floor_1',
    connectedNodeIds: ['node_stairs_f1', 'node_hod_office'],
  ),
  NodeModel(
    id: 'node_hod_office',
    x: 200,
    y: 150,
    floorId: 'main_floor_1',
    locationId: 'loc_hod_office',
    connectedNodeIds: ['node_corridor_f1_1'],
  ),
];
