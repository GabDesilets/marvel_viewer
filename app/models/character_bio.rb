class CharacterBio
  attr_reader :real_name, :height, :weight, :powers, :abilities, :groups_aff, :first_app, :origin

  def initialize(real_name, height, weight, powers, abilities, groups_aff, first_app, origin)
    @real_name = real_name
    @height = height
    @weight = weight
    @powers = powers
    @abilities = abilities
    @groups_aff = groups_aff
    @first_app = first_app
    @origin = origin
  end


  def self.get_empty_bio
    self.new(
      "N/A",
      "N/A",
      "N/A",
      "N/A",
      "N/A",
      "N/A",
      "N/A",
      "N/A"
    )
  end
end
