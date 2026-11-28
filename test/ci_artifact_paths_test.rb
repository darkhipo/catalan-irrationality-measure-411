# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class CiArtifactPathsTest < Minitest::Test
  WORKFLOW = YAML.load_file(File.join(__dir__, "..", ".github", "workflows", "ci.yml"))

  def test_cell_artifacts_restore_to_their_lake_directory
    upload = WORKFLOW.dig("jobs", "build-cells", "steps").find do |step|
      step.dig("with", "name") == "cells-oleans-${{ matrix.shard }}"
    end
    refute_nil upload
    lake_cells = upload.dig("with", "path")

    %w[build-top docs].each do |job_name|
      downloads = WORKFLOW.dig("jobs", job_name, "steps").select do |step|
        step.dig("with", "pattern") == "cells-oleans-*"
      end
      assert_equal 1, downloads.length, "#{job_name} must restore the cell artifacts separately"
      assert_equal lake_cells, downloads.first.dig("with", "path"), "#{job_name} flattens the cell artifacts"
    end
  end
end
