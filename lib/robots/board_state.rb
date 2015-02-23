require "equalizer"
require "set"

module Robots
  class BoardState
    include Equalizer.new(:robots, :goal)

    attr_reader :robots

    def initialize(robots, goal)
      @robots = Array(robots)
      @goal = goal
      ensure_active_robot_present
    end

    def with_robot_moved(robot, direction)
      moved_robots = robots.map { |each_robot| each_robot == robot ? each_robot.moved(direction, self) : each_robot }
      self.class.new(moved_robots, goal)
    end

    def with_goal(new_goal)
      self.class.new(robots.dup, new_goal)
    end

    def ensure_active_robot_first
      goal_index = robots.index { |robot| robot.active?(goal) }
      robots.rotate!(goal_index)
    end

    def stopping_cell(cell, stop)
      robots.inject(stop) do |result, robot|
        robot.cell != cell && robot.between?(cell, result) ? robot.neighbor_nearest(cell) : result
      end
    end

    def home_robot
      robots.find { |robot| robot.home?(goal) }
    end

    def game_over?
      !home_robot.nil?
    end

    def to_s
      "  " + robots.map(&:to_s).join("\n  ") + "\nAttempting to solve for #{goal}"
    end

    private

    attr_reader :goal

    def ensure_active_robot_present
      robots.unshift(robots.shift.with_color(goal.color)) unless robots.any? { |robot| robot.active?(goal) }
    end
  end
end
