require 'ruby2d'

set width: 600, height: 600, title: "Game Of Life"

class Cell
  attr :color, :alive

  def initialize(x: 0, y: 0)
    @square = Square.new(
      x: x, y: y,
      size: 14,
      color: 'white'
    )

    @alive = false

    check_status
  end

  def revive
    @alive = true

    check_status
  end

  def die
    @alive = false

    check_status
  end

  def check_status
    @square.color = @alive ? 'white' : [0,0,0,0.0]
  end

  def is_alive
    alive
  end

  def color=(color)
    @square.color = color
  end
end

class Grid
  def initialize
    @cells = setup_grid
  end

  def setup_grid
    cells = []

    40.times do |i|
      row = []

      40.times do |j|
        row.push Cell.new(
          x: j * 15, y: i * 15
        )
      end

      cells.push row
    end

    cells
  end

  def hover_cell(x: 0, y: 0)
    clear_cells

    @cells[y][x].color = [1,1,1,0.5]
  end

  def revive_cell(x: 0, y: 0)
    @cells[y][x].revive
  end

  def kill_cell(x: 0, y: 0)
    @cells[y][x].die
  end

  def clear_cells
    @cells.each { |i| i.each { |j|
      j.color = j.alive ? 'white' : [0,0,0,0.0]
    } }
  end

  def eval_future
    cells = []

    40.times do |i|
      row = []

      40.times do |j|
        current_cell = @cells[i][j]
        neighbors = 0

        neighbors += 1 if @cells[i-1] && @cells[i-1][j-1] && @cells[i-1][j-1].is_alive
        neighbors += 1 if @cells[i-1] && @cells[i-1][j] && @cells[i-1][j].is_alive
        neighbors += 1 if @cells[i-1] && @cells[i-1][j+1] && @cells[i-1][j+1].is_alive
        neighbors += 1 if @cells[i] && @cells[i][j-1] && @cells[i][j-1].is_alive
        neighbors += 1 if @cells[i] && @cells[i][j+1] && @cells[i][j+1].is_alive
        neighbors += 1 if @cells[i+1] && @cells[i+1][j-1] && @cells[i+1][j-1].is_alive
        neighbors += 1 if @cells[i+1] && @cells[i+1][j] && @cells[i+1][j].is_alive
        neighbors += 1 if @cells[i+1] && @cells[i+1][j+1] && @cells[i+1][j+1].is_alive

        if (current_cell.is_alive) && (neighbors > 3)
          row.push false
        elsif (current_cell.is_alive) && (neighbors == 2 || neighbors == 3)
          row.push true
        elsif !(current_cell.is_alive) && (neighbors == 3)
          row.push true
        else
          row.push false
        end
      end

      cells.push row
    end

    @future_cells = cells
  end

  def exec_future
    40.times do |i|
      40.times do |j|
        @cells[i][j].revive if @future_cells[i][j]
        @cells[i][j].die unless @future_cells[i][j]
      end
    end
  end
end

class InfoBox
  attr :text

  def initialize(x: 0, y: 0)
    Rectangle.new(
      x: x, y: y,
      width: 110, height: 20,
      color: [0, 0, 0, 0.5],
      z: 10
    )

    @label = Text.new(
      self.text,
      x: x + 5, y: y + 3,
      z: 11,
      size: 10,
      color: 'white'
    )
  end

  def text=(text)
    @label.text = text
  end
end

grid = Grid.new
info_box = InfoBox.new x: 5, y: 5
state_box = InfoBox.new x: 5, y: 575

on :mouse_down do |event|
  x_cell = (event.x / 15).to_i
  y_cell = (event.y / 15).to_i

  if event.button == :left
    grid.revive_cell(
      x: x_cell,
      y: y_cell
    )
  elsif event.button == :right
    grid.kill_cell(
      x: x_cell,
      y: y_cell
    )
  end
end

playing = false
tick = 0

on :key_down do |event|
  if event.key == "space"
    playing = !playing
  end
end

on :mouse do |event|
  x_cell = (event.x / 15).to_i
  y_cell = (event.y / 15).to_i

  grid.hover_cell(
    x: x_cell,
    y: y_cell
  )

  info_box.text = "Column: #{x_cell + 1}  Row: #{y_cell + 1}"
end

update do
  if tick % 15 == 0 && playing
    grid.eval_future
    grid.exec_future
  end

  state_box.text = "#{playing ? "Playing" : "Paused"}"

  tick += 1
end

show