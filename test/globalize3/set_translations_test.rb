# encoding: utf-8

require File.expand_path('../../test_helper', __FILE__)

class AttributesTest < Test::Unit::TestCase
  test "set_translations sets multiple translations at once" do
    post = Post.create(:title => 'title', :content => 'content', :locale => :en)
    post.update_attributes(:title => 'Titel', :content => 'Inhalt', :locale => :de)

    post.set_translations(
      :en => { :title => 'updated title', :content => 'updated content' },
      :de => { :title => 'geänderter Titel', :content => 'geänderter Inhalt' }
    )
    post.reload

    assert_translated post, :en, [:title, :content], ['updated title', 'updated content']
    assert_translated post, :de, [:title, :content], ['geänderter Titel', 'geänderter Inhalt']
  end

  test "set_translations does not touch existing translations for other locales" do
    post = Post.create(:title => 'title', :content => 'content', :locale => :en)
    post.update_attributes(:title => 'Titel', :content => 'Inhalt', :locale => :de)

    post.set_translations(:en => { :title => 'updated title', :content => 'updated content' })
    post.reload

    assert_translated post, :en, [:title, :content], ['updated title', 'updated content']
    assert_translated post, :de, [:title, :content], ['Titel', 'Inhalt']
  end

  test "set_translations does not touch existing translations for other attributes" do
    post = Post.create(:title => 'title', :content => 'content', :locale => :en)
    post.update_attributes(:title => 'Titel', :content => 'Inhalt', :locale => :de)

    post.set_translations(
      :en => { :title => "updated title" },
      :de => { :content => "geänderter Inhalt" }
    )
    post.reload

    assert_translated post, :en, [:title, :content], ['updated title', 'content']
    assert_translated post, :de, [:title, :content], ['Titel', 'geänderter Inhalt']
  end

  test "set_translations raises an UnknownAttributeError on unknown attributes" do
    post = Post.create(:title => 'title', :content => 'content', :locale => :en)
    post.update_attributes(:title => 'Titel', :content => 'Inhalt', :locale => :de)

    options = { :de => { :does_not_exist => 'should raise' } }
    assert_raises(ActiveRecord::UnknownAttributeError, 'unknown attribute: does_not_exist') do
      post.set_translations options
    end
  end
end