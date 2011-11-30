class MergeRequest < ActiveRecord::Base
  belongs_to :project
  belongs_to :author, :class_name => "User"
  belongs_to :assignee, :class_name => "User"
  has_many :notes, :as => :noteable

  attr_protected :author, :author_id, :project, :project_id

  validates_presence_of :project_id
  validates_presence_of :assignee_id
  validates_presence_of :author_id
  validates_presence_of :source_branch
  validates_presence_of :target_branch

  delegate :name,
           :email,
           :to => :author,
           :prefix => true

  delegate :name,
           :email,
           :to => :assignee,
           :prefix => true

  validates :title,
            :presence => true,
            :length   => { :within => 0..255 }

  scope :opened, where(:closed => false)
  scope :closed, where(:closed => true)
  scope :assigned, lambda { |u| where(:assignee_id => u.id)}

  def new?
    today? && created_at == updated_at
  end

  def diffs
    commit = project.commit(source_branch)
    commits = project.repo.commits_between(target_branch, source_branch).map {|c| Commit.new(c)}
    diffs = project.repo.diff(commits.first.prev_commit.id, commits.last.id)
  end

  def last_commit
    project.commit(source_branch)
  end
end
