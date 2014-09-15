/*
 *  The Syncro Soft SRL License
 *
 *  Copyright (c) 1998-2007 Syncro Soft SRL, Romania.  All rights
 *  reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *  1. Redistribution of source or in binary form is allowed only with
 *  the prior written permission of Syncro Soft SRL.
 *
 *  2. Redistributions of source code must retain the above copyright
 *  notice, this list of conditions and the following disclaimer.
 *
 *  3. Redistributions in binary form must reproduce the above copyright
 *  notice, this list of conditions and the following disclaimer in
 *  the documentation and/or other materials provided with the
 *  distribution.
 *
 *  4. The end-user documentation included with the redistribution,
 *  if any, must include the following acknowledgment:
 *  "This product includes software developed by the
 *  Syncro Soft SRL (http://www.sync.ro/)."
 *  Alternately, this acknowledgment may appear in the software itself,
 *  if and wherever such third-party acknowledgments normally appear.
 *
 *  5. The names "Oxygen" and "Syncro Soft SRL" must
 *  not be used to endorse or promote products derived from this
 *  software without prior written permission. For written
 *  permission, please contact support@oxygenxml.com.
 *
 *  6. Products derived from this software may not be called "Oxygen",
 *  nor may "Oxygen" appear in their name, without prior written
 *  permission of the Syncro Soft SRL.
 *
 *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *  DISCLAIMED.  IN NO EVENT SHALL THE SYNCRO SOFT SRL OR
 *  ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 *  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 *  USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 *  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 *  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 *  OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 *  SUCH DAMAGE.
 */
package ro.sync.ecss.component.editor.custom;
import java.awt.Component;
import java.awt.Cursor;
import java.awt.Dimension;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
 
/**
 * Class used to make an undecorated component resizeable.
 */
public class ComponentResizer extends MouseAdapter {
  /**
   * The border in which we will enable the drag support.
   */
  private static final int RESIZE_MARGIN_SIZE = 10;
  /**
   * Resize information for a current mouse location. 
   */
  public class CursorResizerInfo {
    /**
     * <code>true</code> if we are currently resizing horizontally to the east.
     */
    private boolean resizeHorizontalEast = false;
    /**
     * <code>true</code> if we are currently resizing vertically to the north.
     */
    private boolean resizeVerticalNorth = false;
    /**
     * <code>true</code> if we are currently resizing horizontally to the west.
     */
    private boolean resizeHorizontalWest = false;
    /**
     * <code>true</code> if we are currently resizing vertically to the south.
     */
    private boolean resizeVerticalSouth = false;
    /**
     * The current cursor.
     */
    private int cursorType = Cursor.DEFAULT_CURSOR;
    
    /**
     * Reset inner fields to the no resize state.
     */
    public void reset() {
      resizeHorizontalEast = false;
      resizeHorizontalWest = false;
      resizeVerticalNorth = false;
      resizeVerticalSouth = false;

      cursorType = Cursor.DEFAULT_CURSOR;
    }
    
    /**
     * @return Returns the cursorType.
     */
    public int getCursorType() {
      return cursorType;
    }
  }
  
  /**
   * <code>true</code> if resizing to the east is allowed.
   */
  private boolean allowResizeToEast = true;
  /**
   * <code>true</code> if resizing to the north is allowed.
   */
  private boolean allowResizeToNorth = true;
  /**
   * <code>true</code> if resizing to the west is allowed.
   */
  private boolean allowResizeToWest = true;
  /**
   * <code>true</code> if resizing to the south is allowed.
   */
  private boolean allowResizeToSouth = true;
  
  /**
   * The maximum rectangle whose bounds shouldn't be crossed.
   * The component should be resized within this rectangle.
   */
  private Rectangle maxBounds = null; 
  
  /**
   * The minimum size of the resizable component.
   */
  private Dimension minSize = new Dimension(0,0);
  /**
   * The component to resize.
   */
  private Component resizeableComp;
  /**
   * <code>true</code> if currently resizing.
   */
  private boolean isResizing;
  /**
   * Current resize information based on the mouse location.
   */
  private CursorResizerInfo cursorResizeInfo = new CursorResizerInfo();
  
  /**
   * Constructor.
   * @param component The component to install the resize for.
   */
  public ComponentResizer(Component component) {
    resizeableComp = component;
    component.addMouseListener(this);
    component.addMouseMotionListener(this);
  }
  
  /**
   * Set the mouse cursor type.
   * @see java.awt.event.MouseAdapter#mouseEntered(java.awt.event.MouseEvent)
   */
  @Override
  public void mouseEntered(MouseEvent me) {
    if (!isResizing) {
      setCursorType(me.getPoint());
    }
  }
  
  /**
   * @see java.awt.event.MouseAdapter#mousePressed(java.awt.event.MouseEvent)
   */
  @Override
  public void mousePressed(MouseEvent e) {
    // For author form controls the mouseEntered might be skipped.
    if (!isResizing) {
      setCursorType(e.getPoint());
    }
    e.consume();
  }
  
  /**
   * Set the cursor type corresponding to the point.
   * @param point The current point.
   */
  private void setCursorType(Point point) {
    cursorResizeInfo = getCursorType(point, resizeableComp.getBounds());
    Cursor cursor = Cursor.getPredefinedCursor(cursorResizeInfo.cursorType);
    updateCursor(cursor);
  }

  /**
   * Updates the cursor in the watched component.
   * 
   * @param cursor Current cursor.
   */
  protected void updateCursor(Cursor cursor) {
    resizeableComp.setCursor(cursor);
  }

  /**
   * Compute the cursor type for the given point and component bounds. If the point is
   * over the resizing areas a resize cursor is returned.
   * 
   * @param point Mouse location.
   * @param bounds Component bounds.
   * 
   * @return Resize information.
   */
  public CursorResizerInfo getCursorType(Point point, Rectangle bounds) {
    CursorResizerInfo info = new CursorResizerInfo();
    
    // Determine if should resize to the south
    info.resizeVerticalSouth = 
        allowResizeToSouth && (point.y <= bounds.height) && (point.y >= bounds.height - RESIZE_MARGIN_SIZE);
    // Determine if should resize to the east
    info.resizeHorizontalEast = 
        allowResizeToEast &&(point.x <= bounds.width) && (point.x >= bounds.width - RESIZE_MARGIN_SIZE);
    // Determine if should resize to the west
    info.resizeHorizontalWest = 
        allowResizeToWest && (point.x >= 0) && (point.x <= RESIZE_MARGIN_SIZE);
    // Determine if should resize to the north
    info.resizeVerticalNorth = 
        allowResizeToNorth && (point.y >= 0) && (point.y <= RESIZE_MARGIN_SIZE);      
          
    info.cursorType = Cursor.DEFAULT_CURSOR;
    if (info.resizeHorizontalEast) {
      if (info.resizeVerticalSouth) {
        info.cursorType = Cursor.SE_RESIZE_CURSOR;
      } else if (info.resizeVerticalNorth){
        info.cursorType = Cursor.NE_RESIZE_CURSOR;
      } else { 
        info.cursorType = Cursor.E_RESIZE_CURSOR;
      }
    } else if (info.resizeHorizontalWest) {
      if (info.resizeVerticalSouth) {
        info.cursorType = Cursor.SW_RESIZE_CURSOR;
      } else if (info.resizeVerticalNorth){
        info.cursorType = Cursor.NW_RESIZE_CURSOR;
      } else { 
        info.cursorType = Cursor.W_RESIZE_CURSOR;
      }
    } else  if(info.resizeVerticalSouth) {
      info.cursorType = Cursor.S_RESIZE_CURSOR;
    } else  if(info.resizeVerticalNorth) {
      info.cursorType = Cursor.N_RESIZE_CURSOR;
    }
    
    return info;
  }
  
  /**
   * @see java.awt.event.MouseAdapter#mouseExited(java.awt.event.MouseEvent)
   */
  @Override
  public void mouseExited(MouseEvent e) {
    if (!isResizing) {
      updateCursor(Cursor.getPredefinedCursor(Cursor.DEFAULT_CURSOR));
    }
  }
  
  /**
   * Reset the drag type.
   * @see java.awt.event.MouseAdapter#mouseReleased(java.awt.event.MouseEvent)
   */
  @Override
  public void mouseReleased(MouseEvent me) {
	// Reset flags
    isResizing = false;
    cursorResizeInfo.reset();
  }
  
  /**
   * Set the mouse cursor type.
   */
  @Override
  public void mouseMoved(MouseEvent me) {
    isResizing = false;
    setCursorType(me.getPoint());
  }
  
  @Override
  public void mouseDragged(MouseEvent me) {
    isResizing = true;
    Rectangle bounds = resizeableComp.getBounds();
    
    int newX =  bounds.x;
    int newY = bounds.y;
    int newWidth = bounds.width;
    int newHeight = bounds.height;
    
    Point p = me.getPoint();
    if (cursorResizeInfo.resizeHorizontalEast) {
      newWidth = p.x;
    } 
    if (cursorResizeInfo.resizeHorizontalWest) {
      newX = bounds.x + p.x;
      newWidth = bounds.width - p.x;
    } 
    if (cursorResizeInfo.resizeVerticalSouth) {
      newHeight = p.y;
    } 
    if (cursorResizeInfo.resizeVerticalNorth) {
      newHeight = bounds.height - p.y;
      newY = bounds.y + p.y;
    }
    // Ensure that the maximum bounds and the minimum size is respected.
    if (((maxBounds == null) || (newX >= maxBounds.x) && (newX + newWidth <= maxBounds.x + maxBounds.width) &&
        (newY >= maxBounds.y) && (newY + newHeight <= maxBounds.y + maxBounds.height)) &&
        (newWidth >= minSize.width) && (newHeight >= minSize.height)) {
      // Set the new component bounds.
      resizeableComp.setBounds(newX, newY, newWidth, newHeight);
      resizeableComp.invalidate();
      resizeableComp.validate();
      resizeableComp.repaint();
      
    }
    // We are resizing so we should consume the event.
    me.consume();
  }
  
  /**
   * Sets whether resizing to the north is allowed.
   * @param allowResizeToNorth <code>true</code> if resizing to the north is allowed.
   */
  public void setAllowResizeToNorth(boolean allowResizeToNorth) {
    this.allowResizeToNorth = allowResizeToNorth;
  }
  
  /**
   * Sets whether resizing to the east is allowed.
   * @param allowResizeToEast <code>true</code> if resizing to the east is allowed.
   */
  public void setAllowResizeToEast(boolean allowResizeToEast) {
    this.allowResizeToEast = allowResizeToEast;
  }
  
  /**
   * Sets whether resizing to the south is allowed.
   * @param allowResizeToSouth <code>true</code> if resizing to the south is allowed.
   */
  public void setAllowResizeToSouth(boolean allowResizeToSouth) {
    this.allowResizeToSouth = allowResizeToSouth;
  }
  
  /**
   * Sets whether resizing to the west is allowed.
   * @param allowResizeToWest <code>true</code> if resizing to the west is allowed.
   */
  public void setAllowResizeToWest(boolean allowResizeToWest) {
    this.allowResizeToWest = allowResizeToWest;
  }
  
  /**
   * Sets the minimum size the component should be resized to.
   * @param minSize The minSize to set.
   */
  public void setMinimumSize(Dimension minSize) {
    this.minSize = minSize;
  }
  
  /**
   * Sets the maximum bounds of the component.
   * @param maxBounds The maxBounds to set.
   */
  public void setMaxBounds(Rectangle maxBounds) {
    this.maxBounds = maxBounds;
  }
  
  /**
   * @return <code>true</code> if we are currently resizing
   * the component.
   */
  public boolean isResizing() {
    return isResizing;
  }
}
