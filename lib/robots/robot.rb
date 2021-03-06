require_relative "cell"
require "equalizer"

module Robots
  class Robot
    include Equalizer.new(:color, :cell)

    attr_reader :color, :cell

    def initialize(color, cell)
      @color = color.downcase.to_sym
      @cell = cell
    end

    def moved(direction, board_state)
      next_cell = cell.next_cell(direction, board_state)
      next_cell == cell ? self : self.class.new(color, next_cell)
    end

    def with_color(new_color)
      self.class.new(new_color, cell)
    end

    def neighbor_nearest(other_cell)
      cell.neighbor_nearest(other_cell)
    end

    def position_hash
      cell.position_hash
    end

    def between?(first_cell, second_cell)
      cell.between?(first_cell, second_cell)
    end

    def home?(goal)
      active?(goal) && cell.goal?(goal)
    end

    def active?(goal)
      goal.matches_color?(color)
    end

    def to_command_line_args
      "-r #{color},#{cell.to_command_line_args}"
    end

    def to_s
      "The #{color} robot is at #{cell}."
    end
  end
end
