class TutorialController < ApplicationController
    def evaluate_for_newbie
        render layout: "../tutorial_layouts/application.html.erb"
    end
end
