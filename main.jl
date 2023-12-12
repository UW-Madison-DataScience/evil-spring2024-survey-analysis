#!/usr/bin/env julia

using CSV
using DataFrames
using EpistemicNetworkAnalysis
using Plots

# Load data
## NOTE: download data from
## https://docs.google.com/spreadsheets/d/1o7pOMaPR3BNWrKzkcyX883f4eHovXHWfIaxpjUkOT1o/edit?resourcekey#gid=1499019000
data = DataFrame(CSV.File("data/data.csv"))

# Clean data
preference_map = Dict(
    "Not preferred" => 0,
    "Somewhat preferred" => 0,
    "Less preferred" => 1,
    "Very preferred" => 1
)

importance_map = Dict(
    "Unimportant" => 0,
    "Somewhat important" => 0,
    "Less important" => 1,
    "Very important" => 1
)

communication_column_name_map = Dict(
    "How preferred are the following for you to receive EVIL Reading Group announcements? [Slack]" => :Slack,
    "How preferred are the following for you to receive EVIL Reading Group announcements? [Discord]" => :Discord,
    "How preferred are the following for you to receive EVIL Reading Group announcements? [Email (Google Group)]" => :Google,
    "How preferred are the following for you to receive EVIL Reading Group announcements? [Email (Newsletter)]" => :Newsletter,
    "How preferred are the following for you to receive EVIL Reading Group announcements? [Facebook Group]" => :Facebook,
    "How preferred are the following for you to receive EVIL Reading Group announcements? [Mastodon]" => :Mastodon,
    "How preferred are the following for you to receive EVIL Reading Group announcements? [Microsoft Teams]" => :Teams,
)

activity_column_name_map = Dict(
    "How important are the following to you as a member of the EVIL Reading Group? [Reading interesting papers and cases]" => :Reading,
    "How important are the following to you as a member of the EVIL Reading Group? [Discussing AI Ethics with my peers]" => :Discussing,
    "How important are the following to you as a member of the EVIL Reading Group? [Networking and meeting new people]" => :Networking,
    "How important are the following to you as a member of the EVIL Reading Group? [Staying up to date on AI Ethics papers and cases]" => :Current,
    "How important are the following to you as a member of the EVIL Reading Group? [Learning methods for thinking through AI Ethics moral questions]" => :Moral,
    "How important are the following to you as a member of the EVIL Reading Group? [Learning methods for making AI systems more fair, etc.]" => :Making,
    "How important are the following to you as a member of the EVIL Reading Group? [Speaking with peers and advisors about my professional development]" => :Professional,
    "How important are the following to you as a member of the EVIL Reading Group? [Hands-on demonstrations of AI Ethics issues]" => :Demonstrations,
)

for (long, short) in communication_column_name_map
    data[!, short] = map(data[:, long]) do value
        return preference_map[value]
    end
end

for (long, short) in activity_column_name_map
    data[!, short] = map(data[:, long]) do value
        return importance_map[value]
    end
end

# Configure models
comm_codes = collect(values(communication_column_name_map))
acti_codes = collect(values(activity_column_name_map))
conversations = [:Email]
units = [:Email]

# Construct models
comm_model = BiplotENAModel(data, comm_codes, conversations, units)
acti_model = BiplotENAModel(data, acti_codes, conversations, units)

# Visualize
comm_plot = plot(comm_model)
acti_plot = plot(acti_model)
display(comm_plot)
display(acti_plot)
savefig(comm_plot, "communication_svd.svg")
savefig(acti_plot, "activities_svd.svg")