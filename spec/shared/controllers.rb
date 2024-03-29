module SharedControllerSpecs

  shared_examples "auto complete" do |route|
    before(:each) do
      @query = "Hello"
    end

    it "should do the search and find records that match autocomplete query" do
      post :auto_complete, :auto_complete_query => @query, :use_route => route
      assigns[:query].should == @query
      assigns[:auto_complete].should == @auto_complete_matches # Each controller must define it.
    end

    it "should save current autocomplete controller in a session" do
      post :auto_complete, :auto_complete_query => @query, :use_route => route

      # We don't save Admin/Users autocomplete controller in a session since Users are not
      # exposed through the Jumpbox.
      unless controller.class.to_s.starts_with?("Admin::")
        session[:auto_complete].should == @controller.controller_name.to_sym
      end
    end

    it "should render application/_auto_complete template" do
      post :auto_complete, :auto_complete_query => @query, :use_route => route
      response.should render_template("application/_auto_complete")
    end
  end

  shared_examples "attach" do
    it "should attach existing asset to the parent asset of different type" do
      xhr :put, :attach, :id => @model.id, :assets => @attachment.class.name.tableize, :asset_id => @attachment.id
      @model.send(@attachment.class.name.demodulize.tableize).should include(@attachment)
      assigns[:attachment].should == @attachment
      assigns[:attached].should == [ @attachment ]
      if @model.is_a?(FatFreeCrm::Campaign) && (@attachment.is_a?(FatFreeCrm::Lead) || @attachment.is_a?(FatFreeCrm::Opportunity))
        assigns[:campaign].should == @attachment.reload.campaign
      end
      if @model.is_a?(FatFreeCrm::Account) && @attachment.respond_to?(:account) # Skip Tasks...
        assigns[:account].should == @attachment.reload.account
      end
      response.should render_template("entities/attach")
    end

    it "should not attach the asset that is already attached" do
      if @model.is_a?(FatFreeCrm::Campaign) && (@attachment.is_a?(FatFreeCrm::Lead) || @attachment.is_a?(FatFreeCrm::Opportunity))
        @attachment.update_attribute(:campaign_id, @model.id)
      else
        @model.send(@attachment.class.name.demodulize.tableize) << @attachment
      end

      xhr :put, :attach, :id => @model.id, :assets => @attachment.class.name.tableize, :asset_id => @attachment.id
      assigns[:attached].should == nil
      response.should render_template("entities/attach")
    end

    it "should display flash warning when the model is no longer available" do
      @model.destroy

      xhr :put, :attach, :id => @model.id, :assets => @attachment.class.name.tableize, :asset_id => @attachment.id
      flash[:warning].should_not == nil
      response.body.should == "window.location.reload();"
    end
    it "should display flash warning when the attachment is no longer available" do
      @attachment.destroy

      xhr :put, :attach, :id => @model.id, :assets => @attachment.class.name.tableize, :asset_id => @attachment.id
      flash[:warning].should_not == nil
      response.body.should == "window.location.reload();"
    end
  end

  shared_examples "discard" do
    it "should discard the attachment without deleting it" do
      xhr :post, :discard, :id => @model.id, :attachment => @attachment.class.name, :attachment_id => @attachment.id
      assigns[:attachment].should == @attachment.reload                     # The attachment should still exist.
      @model.reload.send("#{@attachment.class.name.demodulize.tableize}").should == [] # But no longer associated with the model.
      assigns[:account].should == @model if @model.is_a?(FatFreeCrm::Account)
      assigns[:campaign].should == @model if @model.is_a?(FatFreeCrm::Campaign)

      response.should render_template("entities/discard")
    end

    it "should display flash warning when the model is no longer available" do
      @model.destroy

      xhr :post, :discard, :id => @model.id, :attachment => @attachment.class.name, :attachment_id => @attachment.id
      flash[:warning].should_not == nil
      response.body.should == "window.location.reload();"
    end

    it "should display flash warning when the attachment is no longer available" do
      @attachment.destroy

      xhr :post, :discard, :id => @model.id, :attachment => @attachment.class.name, :attachment_id => @attachment.id
      flash[:warning].should_not == nil
      response.body.should == "window.location.reload();"
    end
  end
end
