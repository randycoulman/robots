module Robots
  module Solvers
    class Dfs < Solver
      private

      def candidates
        @candidates ||= []
      end

      def solve
        solve_recursively(Path.initial(state, goal))
        record_stats
        candidates.min_by(&:length) || Outcome.no_solution(state)
      end

      def solve_recursively(path)
        note_state_considered

        return candidates << path.to_outcome if path.solved?

        path.allowable_successors.each do |successor|
          solve_recursively(successor)
        end
      end

      def record_stats
        stats.solutions_found = candidates.size
        longest_solution = candidates.max_by(&:length)
        stats.longest_solution = longest_solution ? longest_solution.length : 0
      end
    end
  end
end