class Room
  attr_reader :room_data, :tiles, :filename

  COMMENT_CHARACTER = '#'.freeze
  ROOM_WIDTH = 864
  ROOM_HEIGHT = 480
  TILE_SIZE = 32

  # A singular tile in the room.
  # @param x [Integer]
  Tile = Data.define(:x, :y, :w, :h, :type)

  # Create a new room.
  # @param data [Array]
  def initialize(data)
    @room_data = data
    @tiles = {}

    generate_tiles(@room_data, tiles)
  end

  # Generates Tile objects for the room.
  # @param data [Array] The room data.
  # @param tiles [Hash] Where to save the tiles.
  def generate_tiles(data, tiles)
    data.each_with_index do |row, y|
      row.each_with_index do |column, x|
        case column
        when '0'
          next
        when '1'
          tiles[:walls] ||= []
          tiles[:walls] << Tile.new(x * TILE_SIZE, y * TILE_SIZE,
                                    TILE_SIZE, TILE_SIZE,
                                    column.to_i)
        when '@'
          tiles[:spawn] = Tile.new(x * TILE_SIZE, y * TILE_SIZE,
                                   TILE_SIZE, TILE_SIZE,
                                   column)
        end
      end
    end
  end

  # @param path [String] Path to the room data.
  # TODO: Remove line parsing from here to its own dedicated method
  def self.load_file(path)
    @filename = path

    data = []
    File.open(path, 'r').each_line do |line|
      line.chomp! # Remove newlines
      next if line.chr == COMMENT_CHARACTER || line.empty?

      data << line.split(',')
    end

    Room.new(data)
  end

  # Returns the tile at the specified x and y coordinates.
  # @param x [Integer] The x position.
  # @param y [Integer] The y position.
  def tile_at(x, y)
    t_x = ((x / TILE_SIZE) % TILE_SIZE).floor
    t_y = ((y / TILE_SIZE) % TILE_SIZE).floor
    row = @room_data[t_y]
    row[t_x].to_i if row
  end
end
