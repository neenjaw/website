class Solution
  class GenerateReadmeFile
    include Mandate

    initialize_with :solution

    def call
      [
        preamble,
        introduction,
        instructions,
        source
      ].compact_blank.join("\n\n")
    end

    private
    def preamble
      hints_text = I18n.t("exercises.documents.hints_reference").strip if solution.git_exercise.hints.present?

      welcome_text = I18n.t("exercises.documents.welcome",
        { exercise_title: solution.exercise.title, track_title: solution.track.title }).strip
      help_text = I18n.t("exercises.documents.help_reference").strip

      <<~TEXT.strip
        # #{solution.exercise.title}

        #{welcome_text}
        #{help_text}
        #{hints_text}
      TEXT
    end

    def introduction
      return if solution.git_exercise.introduction.blank?

      introduction_text = Markdown::Render.(solution.git_exercise.introduction, :text).strip
      introduction_append_text = Markdown::Render.(solution.git_exercise.introduction_append, :text).strip

      <<~TEXT.strip
        ## Introduction

        #{introduction_text}

        #{introduction_append_text}
      TEXT
    end

    def instructions
      instructions_text = Markdown::Render.(solution.git_exercise.instructions, :text).strip
      instructions_append_text = Markdown::Render.(solution.git_exercise.instructions_append, :text).strip

      <<~TEXT.strip
        ## Instructions

        #{instructions_text}

        #{instructions_append_text}
      TEXT
    end

    def source
      sources_text = [created_by, contributed_by, based_on].compact_blank.join("\n\n")
      return if sources_text.empty?

      <<~TEXT.strip
        ## Source

        #{sources_text}
      TEXT
    end

    def created_by
      return if solution.git_exercise.authors.blank?

      authors_text = users_list(solution.git_exercise.authors)

      <<~TEXT.strip
        ### Created by

        #{authors_text}
      TEXT
    end

    def contributed_by
      return if solution.git_exercise.contributors.blank?

      contributors_text = users_list(solution.git_exercise.contributors)

      <<~TEXT.strip
        ### Contributed to by

        #{contributors_text}
      TEXT
    end

    def users_list(users)
      users.map do |user|
        if user[:exercism_username].blank?
          "- @#{user[:github_username]}"
        else
          "- #{user[:exercism_username]} (@#{user[:github_username]})"
        end
      end.join("\n")
    end

    def based_on
      return unless solution.git_exercise.source.present? || solution.git_exercise.source_url.present?

      source_text = [solution.git_exercise.source, solution.git_exercise.source_url].compact_blank.join(' - ')

      <<~TEXT.strip
        ### Based on

        #{source_text}
      TEXT
    end
  end
end
