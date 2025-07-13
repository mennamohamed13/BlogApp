class CommentsController < ApplicationController
  before_action :set_post
  before_action :set_comment, only: [:update, :destroy]

  # POST /posts/:post_id/comments
  def create
    return render json: { errors: 'Unauthorized' }, status: :unauthorized unless @current_user

    @comment = @post.comments.build(comment_params.merge(user: @current_user))
    if @comment.save
      render json: @comment, status: :created
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /posts/:post_id/comments/:id
  def update
    return render json: { errors: 'Unauthorized' }, status: :unauthorized unless @current_user

    if @comment.user == @current_user
      if @comment.update(comment_params)
        render json: @comment
      else
        render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { errors: 'Not authorized to update this comment' }, status: :unauthorized
    end
  end

  # DELETE /posts/:post_id/comments/:id
  def destroy
    return render json: { errors: 'Unauthorized' }, status: :unauthorized unless @current_user

    if @comment.user == @current_user
      @comment.destroy
      head :no_content
    else
      render json: { errors: 'Not authorized to delete this comment' }, status: :unauthorized
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def comment_params
    params.permit(:body)
  end
end
