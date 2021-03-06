require 'matrix'
class SkillSet < ActiveRecord::Base
  belongs_to :user
  @@feature_cols = [:ruby_on_rails, :other_backend, :frontend, :ui_design, :team_management]
  def toArray
    return @@feature_cols.map {|col_name| self[col_name]}
  end

  def toString
    return (@@feature_cols.select {|skill| self[skill] == 1}).join(', ').gsub('_', ' ').titleize
  end

  def feature_cols
    return @@feature_cols
  end

  def skillCorrelation(otherSkillSet)
    arr = Vector.elements(self.toArray,true)
    arr2 = Vector.elements(otherSkillSet.toArray,true)
    return arr.inner_product arr2
  end

end