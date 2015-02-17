require "spec_helper"

module Robots
  describe Path do
    let(:goal) { instance_double(Target) }
    let(:state) { fake_state("start state") }
    let(:intermediate_state) { fake_state("intermediate state") }
    let(:final_state) { fake_state("final state") }
    let(:initial_path) { Path.initial(state, goal) }
    let(:path) { initial_path.successor(:up).successor(:left) }

    def fake_state(name = "state")
      instance_double(BoardState, name, :game_over? => false, robots: [instance_double(Robot, name)])
    end

    def game_over(state)
      allow(state).to receive(:game_over?).with(goal) { true }
    end

    before do
      allow(state).to receive(:with_robot_moved) { intermediate_state }
      allow(intermediate_state).to receive(:with_robot_moved) { final_state }
    end

    describe "solving" do
      context "when the state is solved" do
        before do
          game_over(path.state)
        end

        context "when the path is long enough" do
          it "is solved" do
            expect(path).to be_solved
          end
        end

        context "when the path is too short" do
          let(:path) { initial_path.successor(:down) }

          it "is not solved" do
            expect(path).not_to be_solved
          end
        end
      end

      context "when not on the goal cell" do
        it "is not solved" do
          expect(path).not_to be_solved
        end
      end
    end

    describe "converting to outcome" do
      let(:outcome) { path.to_outcome }

      context "when solved" do
        before do
          game_over(path.state)
        end

        it "returns a solved outcome" do
          expect(outcome).to be_mission_accomplished
        end

        it "includes the final robot position" do
          expect(outcome.final_state).to be final_state
        end

        it "includes the moves" do
          expect(outcome.length).to eq 2
        end
      end

      context "when not solved" do
        it "returns an unsolved outcome" do
          expect(outcome).not_to be_mission_accomplished
        end

        it "includes the final robot position" do
          expect(outcome.final_state).to be final_state
        end
      end
    end

    describe "successor" do
      let(:direction) { :left }
      let(:successor) { initial_path.successor(direction) }
      let(:next_state) { fake_state("next state") }

      before do
        allow(state).to receive(:with_robot_moved).with(Object, direction) { next_state }
      end

      context "when the robot can move" do
        it "moves the robot" do
          expect(successor.state).to be next_state
        end

        it "appends the move" do
          expect(successor.moves.last).to eq direction
        end

        it "visits the state" do
          expect(successor.visited).to include state
        end
      end

      context "when the robot can't move" do
        let(:next_state) { state }

        it "returns nil" do
          expect(successor).to be nil
        end
      end
    end

    describe "cycle detection" do
      context "when there is a cycle" do
        let(:final_state) { state }

        context "when starting on the goal cell" do
          before do
            game_over(state)
          end

          it "doesn't detect a cycle" do
            expect(path).not_to be_cycle
          end
        end

        context "when starting one move from the goal cell" do
          before do
            game_over(intermediate_state)
          end

          it "doesn't detect a cycle" do
            expect(path).not_to be_cycle
          end
        end

        context "when starting away from the goal cell" do
          it "detects a cycle" do
            expect(path).to be_cycle
          end
        end
      end

      context "when there is not a cycle" do
        it "doesn't detect a cycle" do
          expect(path).not_to be_cycle
        end
      end
    end

    describe "allowable successors" do
      let(:successors) { path.allowable_successors }
      let(:successor_moves) { successors.map { |succ| succ.moves.last } }

      context "for the initial move" do
        let(:path) { initial_path }

        it "follows all four directions" do
          expect(successors.size).to eq 4
        end
      end

      context "for later moves" do
        let(:path) { initial_path.successor(:left).successor(:down) }

        before do
          allow(final_state).to receive(:with_robot_moved) { fake_state }
        end

        it "turns 90 degrees from last move" do
          expect(successor_moves).to eq %i(left right)
        end
      end

      context "when a successor move is blocked" do
        let(:path) { initial_path }

        before do
          allow(state).to receive(:with_robot_moved).with(Object, :left) { state }
        end

        it "excludes it" do
          expect(successor_moves).not_to include :left
        end
      end

      context "when a successor contains a cycle" do
        let(:path) { initial_path.successor(:down).successor(:right) }

        before do
          allow(final_state).to receive(:with_robot_moved).with(Object, :up) { state }
          allow(final_state).to receive(:with_robot_moved).with(Object, :down) { fake_state }
        end

        it "excludes it" do
          expect(successor_moves).not_to include :up
        end
      end
    end
  end
end
