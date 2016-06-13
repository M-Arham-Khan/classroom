# frozen_string_literal: true
module StarterCode
  extend ActiveSupport::Concern

  INVALID_SELECTION = 'Invalid repository selection, please check it again.'
  WRONG_FORMAT      = 'Invalid repository name, use the format owner/name.'

  def starter_code_repository_id(repo_name)
    return unless repo_name.present?

    raise GitHub::Error, WRONG_FORMAT unless repo_name =~ %r{^[a-zA-Z0-9_-]+\/[a-zA-Z0-9_-]+$}

    begin
      GitHubRepository.find_by_name_with_owner!(current_user.github_client, repo_name).id
    rescue GitHub::Error
      raise GitHub::Error, INVALID_SELECTION
    end
  end

  def validate_starter_code_repository_id(repo_id)
    valid_integer_or_number_string = repo_id.is_a?(Integer) || (repo_id.is_a?(String) && repo_id.to_s =~ /^[0-9]+$/)
    raise GitHub::Error, INVALID_SELECTION unless valid_integer_or_number_string

    possible_github_repository = GitHubRepository.new(current_user.github_client, repo_id.to_i).on_github?
    raise GitHub::Error, INVALID_SELECTION unless possible_github_repository.on_github?

    possible_github_repository.id
  end
end
