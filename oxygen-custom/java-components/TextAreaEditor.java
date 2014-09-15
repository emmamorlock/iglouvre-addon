/*
 *  The Syncro Soft SRL License
 *
 *  Copyright (c) 1998-2012 Syncro Soft SRL, Romania.  All rights
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
import java.awt.event.FocusAdapter;
import java.awt.event.FocusEvent;
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;
import java.awt.event.MouseEvent;
import java.util.List;

import javax.swing.BorderFactory;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;
import javax.swing.text.AbstractDocument;
import javax.swing.text.BadLocationException;
import javax.swing.text.PlainDocument;

import ro.sync.ecss.component.editor.custom.ComponentResizer.CursorResizerInfo;
import ro.sync.ecss.css.CSS;
import ro.sync.ecss.extensions.api.AuthorDocumentController;
import ro.sync.ecss.extensions.api.AuthorOperationException;
import ro.sync.ecss.extensions.api.CursorType;
import ro.sync.ecss.extensions.api.editor.AbstractInplaceEditor;
import ro.sync.ecss.extensions.api.editor.AuthorInplaceContext;
import ro.sync.ecss.extensions.api.editor.EditingEvent;
import ro.sync.ecss.extensions.api.editor.InplaceEditorArgumentKeys;
import ro.sync.ecss.extensions.api.editor.InplaceRenderer;
import ro.sync.ecss.extensions.api.editor.RendererLayoutInfo;
import ro.sync.ecss.extensions.api.node.AttrValue;
import ro.sync.ecss.extensions.api.node.AuthorDocumentFragment;
import ro.sync.ecss.extensions.api.node.AuthorElement;
import ro.sync.ecss.extensions.api.node.AuthorNode;
import ro.sync.exml.view.graphics.Dimension;
import ro.sync.exml.view.graphics.Font;
import ro.sync.exml.view.graphics.Point;
import ro.sync.exml.view.graphics.Rectangle;

/**
 * A simple text area based form control.
 */
public class TextAreaEditor extends AbstractInplaceEditor implements InplaceRenderer {
  /**
   * The imposed minimum width for the when the text area computes it's own preferred size.
   */
  private static final int MINIMUM_WIDTH = 400;
  /**
   * The minimum size.
   */
  private static final java.awt.Dimension MINIMUM_SIZE = new java.awt.Dimension(100, 50);
  /**
   * Prefix that marks the custom height. 
   */
  private static final String CUSTOM_HEIGHT_PREFIX = "-custom-height-";
  /**
   * Width that marks the custom width.
   */
  private static final String CUSTOM_WIDTH_PREFIX = "custom-width-";
  /**
   * The default numer of columns.
   */
  public static final int DEFAULT_COLUMNS_NUMBER = 30;

  /**
   * The default number of rows.
   */
  public static final int DEFAULT_ROWS_NUMBER = 10;

  /**
   * The text area with syntax highlighting.
   */
  private JTextArea area;
  
  /**
   * Listener for changes of the document.
   */
  private final DocumentListener editListener;
  
  /**
   * Scroll pane wrapping the text area.
   */
  private JScrollPane scrollPane;
  
  /**
   * Whether the instance is initialized.
   */
  private boolean initialized = false;

  /**
   * The default font of the text area.
   */
  private java.awt.Font defaultFont;
  
  /**
   * Resize support.
   */
  private ComponentResizer componentResizer;
  /**
   * Current editing context.
   */
  private AuthorInplaceContext context;
  
  /**
   * Constructor.
   */
  public TextAreaEditor() {
    // We must fire editingOccured events. Otherwise the author document will 
    // not be updated when the editing session finishes.
    editListener = new DocumentListener() {
      @Override
      public void removeUpdate(DocumentEvent e) {
        fireEditingOccured();
      }

      @Override
      public void insertUpdate(DocumentEvent e) {
        fireEditingOccured();
      }

      @Override
      public void changedUpdate(DocumentEvent e) {
        fireEditingOccured();
      }
    };
  }
  
  /**
   * Initialize the instance according to its use.
   * 
   * The initialization is performed only once.
   * 
   * @param asEditor Whether the instance is going to be used as an editor.
   * @param useTabForIndent <code>true</code> if TAB is used for indentation 
   * instead of navigation.
   */
  private void init(boolean asEditor, final boolean useTabForIndent) {
    if (!initialized) {
      initialized = true;
      
      // Initialize the text area.
      area = new JTextArea() {
        @Override
        protected void processMouseMotionEvent(MouseEvent e) {
          // If we are resizing the area must not process any mouse events.
          if (componentResizer.isResizing()) {
            if (e.getID() == MouseEvent.MOUSE_DRAGGED) {
              componentResizer.mouseDragged(e);
            }
            e.consume();
          } else {
            super.processMouseMotionEvent(e);
          }
        }
      };
      defaultFont = area.getFont();

      // Initialize its containing pane.
      scrollPane = new JScrollPane(area, JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED,
          JScrollPane.HORIZONTAL_SCROLLBAR_AS_NEEDED);
      
      // Resize support.
      componentResizer = new ComponentResizer(scrollPane);
      componentResizer.setMinimumSize(MINIMUM_SIZE);
      componentResizer.setAllowResizeToNorth(false);
      componentResizer.setAllowResizeToWest(false);
      
      scrollPane.setBorder(
          BorderFactory.createCompoundBorder(
              BorderFactory.createEmptyBorder(0, 0, 3, 3), 
              scrollPane.getBorder()));
      scrollPane.setOpaque(false);

      if (asEditor) {
        // Stop the editing session on Enter and Escape.
        area.addKeyListener(new KeyAdapter() {
          @Override
          public void keyPressed(KeyEvent e) {
            if (e.getKeyCode() == KeyEvent.VK_ESCAPE) {
              fireEditingCanceled();
              e.consume();
            } else if (e.getKeyCode() == KeyEvent.VK_ENTER
                && (e.getModifiersEx() & KeyEvent.CTRL_DOWN_MASK) != 0) {
              fireNextEditLocationRequested();
              e.consume();
            } else if (e.getKeyCode() == KeyEvent.VK_TAB) {
              if (!useTabForIndent) {
                e.consume();
                fireEditingOccured();
                if ((e.getModifiersEx() & KeyEvent.SHIFT_DOWN_MASK) != 0) {
                  firePreviousEditLocationRequested();
                } else {
                  fireNextEditLocationRequested();
                }
              }
            }
          }
        });
        
        // Add focus listener to commit the the selected value on focus lost
        area.addFocusListener(new FocusAdapter() {
          @Override
          public void focusLost(FocusEvent e) {
            // Commit but request focus only if there is no focus destination.
            stopEditing(e.getOppositeComponent() == null);
          }
        });
      }
    }
  }

  /**
   * @see ro.sync.ecss.extensions.api.editor.InplaceEditorRendererAdapter#getEditorComponent(ro.sync.ecss.extensions.api.editor.AuthorInplaceContext, ro.sync.exml.view.graphics.Rectangle, ro.sync.exml.view.graphics.Point)
   */
  @Override
  public Object getEditorComponent(AuthorInplaceContext context, Rectangle allocation,
      Point mouseLocation) {
    prepare(context, true);

    return scrollPane;
  }

  /**
   * @see ro.sync.ecss.extensions.api.editor.InplaceEditorRendererAdapter#getValue()
   */
  @Override
  public Object getValue() {
    return area.getText();
  }

  /**
   * @see ro.sync.ecss.extensions.api.editor.InplaceEditorRendererAdapter#stopEditing()
   */
  @Override
  public void stopEditing() {
    stopEditing(true);
  }
  
  /**
   * @see ro.sync.ecss.extensions.api.editor.InplaceEditorRendererAdapter#stopEditing()
   * @param requestFocus Whether to request focus in the author
   */
  private void stopEditing(boolean requestFocus) {
    Runnable runnable = new Runnable() {
      @Override
      public void run() {
        String text = (String) getValue();
        AuthorDocumentController documentController = context.getAuthorAccess().getDocumentController();
        documentController.beginCompoundEdit();
        
        try {
          if (context.getElem().getStartOffset() + 1 < context.getElem().getEndOffset()) {
            documentController.delete(context.getElem().getStartOffset() + 1, context.getElem().getEndOffset() - 1);
          }
          AuthorDocumentFragment frag = documentController.createNewDocumentFragmentInContext(text, context.getElem().getStartOffset() + 1);
          List<AuthorNode> contentNodes = frag.getContentNodes();
          for (AuthorNode authorNode : contentNodes) {
            if (authorNode instanceof AuthorElement) {
              ((AuthorElement) authorNode).setAttribute("xmlns", new AttrValue("http://www.tei-c.org/ns/1.0"));
            }
          }
          documentController.insertFragment(context.getElem().getStartOffset() + 1, frag);
        } catch (AuthorOperationException e) {
          e.printStackTrace();
        } finally {
          documentController.endCompoundEdit();
        }
      }
    };
    fireEditingStopped(new EditingEvent(runnable, requestFocus));
  }

  /**
   * Creates a syntax document.
   * 
   * @param contentType The content type string.
   * @param forEditing <code>true</code> if the document is used for editing.
   * 
   * @return The syntax document.
   */
  private AbstractDocument createDocument(String contentType, boolean forEditing) {
    AbstractDocument newDoc = new PlainDocument();
    newDoc.addDocumentListener(editListener);
    
    return newDoc;
  }
  
  /**
   * Initialize the text area. 
   * 
   * @param context The context of the form control. 
   * @param forEditing Whether this instance is used as an editor or renderer.
   */
  private void prepare(AuthorInplaceContext context, boolean forEditing) {
    this.context = context;
    // Initialize the class according to its function: editor or renderer.
    init(forEditing, true);
    
    // We don't want to generate editingOccured events here, only on user interaction.
    area.getDocument().removeDocumentListener(editListener);
    AuthorDocumentFragment fragment;
    try {
      String content = "";
      if (context.getElem().getStartOffset() + 1 < context.getElem().getEndOffset()) {
        fragment = context.getAuthorAccess().getDocumentController().createDocumentFragment(context.getElem().getStartOffset() + 1, context.getElem().getEndOffset() - 1);
        List<AuthorNode> contentNodes = fragment.getContentNodes();
        for (AuthorNode authorNode : contentNodes) {
          if (authorNode instanceof AuthorElement) {
            ((AuthorElement) authorNode).removeAttribute("xmlns");
          }
        }
        // Set the initial content.
        content = context.getAuthorAccess().getDocumentController().serializeFragmentToXML(fragment);
      }
      area.setText(content);
    } catch (BadLocationException e) {
      // TODO Auto-generated catch block
      e.printStackTrace();
    }
    
    area.getDocument().addDocumentListener(editListener);

    // Set the font.
    Font font = (Font) context.getArguments().get(InplaceEditorArgumentKeys.FONT);
    if (font != null) {
      area.setFont(new java.awt.Font(font.getName(), font.getStyle(), font.getSize()));
    } else {
      area.setFont(defaultFont);
    }
    
    Integer colSet = (Integer) context.getArguments().get(
        InplaceEditorArgumentKeys.PROPERTY_COLUMNS);
    Integer rowSet = (Integer) context.getArguments().get(InplaceEditorArgumentKeys.PROPERTY_ROWS);
    
    // Flag indicating whether we should wrap lines.
    boolean shouldWrap = false;
    
    int columns = 0;
    int rows = 0;
    if (colSet != null || rowSet != null) {
      // Set rows and columns.
      columns = DEFAULT_COLUMNS_NUMBER;
      if (colSet != null) {
        columns = colSet.intValue();
      }
      rows = DEFAULT_ROWS_NUMBER;
      if (rowSet != null) {
        rows = rowSet.intValue();
      }
      
      if (CSS.PRE_WRAP.equals(context.getStyles().getWhitespace())) {
        shouldWrap = true;
      }
    } else {
      // As needed. The preferred size can't be computed because it can adapt to any conditions.
    }
    
    area.setPreferredSize(null);
    scrollPane.setPreferredSize(null);
    area.setRows(rows);
    area.setColumns(columns);
    
    area.setWrapStyleWord(shouldWrap);
    area.setLineWrap(shouldWrap);
    
    // The JScrollPane renderer does not work for a textarea with fixed
    // number of rows and line wrapping. We display it always.
    scrollPane.setVerticalScrollBarPolicy(shouldWrap ? 
        JScrollPane.VERTICAL_SCROLLBAR_ALWAYS : JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED);

    // Needs to be set again since it resets when the document is changed.
    area.setTabSize(4);
    area.setCaretPosition(0);
    
    // Set a minimum size to avoid it being covered by the scrollbar.
    scrollPane.setMinimumSize(MINIMUM_SIZE);
    area.setMinimumSize(MINIMUM_SIZE);
  }

  /**
   * @see ro.sync.ecss.extensions.api.editor.InplaceEditorRendererAdapter#getTooltipText(ro.sync.ecss.extensions.api.editor.AuthorInplaceContext, int, int)
   */
  @Override
  public String getTooltipText(AuthorInplaceContext context, int x, int y) {
    prepare(context, false);
    return area.getText();
  }

  /**
   * @see ro.sync.ecss.extensions.api.editor.InplaceRenderer#getRendererComponent(ro.sync.ecss.extensions.api.editor.AuthorInplaceContext)
   */
  @Override
  public Object getRendererComponent(AuthorInplaceContext context) {
    prepare(context, false);

    return scrollPane;
  }

  /**
   * @see ro.sync.ecss.extensions.api.editor.InplaceRenderer#getRenderingInfo(ro.sync.ecss.extensions.api.editor.AuthorInplaceContext)
   */
  @Override
  public RendererLayoutInfo getRenderingInfo(AuthorInplaceContext context) {
    prepare(context, false);
    java.awt.Dimension preferredSize = scrollPane.getPreferredSize();
    java.awt.Dimension minimumSize = scrollPane.getMinimumSize();
    int width = preferredSize.width;
    int height = preferredSize.height;
    
    if (area.getRows() == 0) {
      // The area has computed its own preferred size. It looks better if it's not too narrow.
      width = Math.max(width, MINIMUM_WIDTH);
    }
    
    // Absolute minimum requirements.
    width = Math.max(width, minimumSize.width);
    height = Math.max(height, minimumSize.height);
    
    Dimension size = new Dimension(width, height);
    return new RendererLayoutInfo(scrollPane.getBaseline(width, height), size);
  }

  /**
   * @see ro.sync.ecss.extensions.api.Extension#getDescription()
   */
  @Override
  public String getDescription() {
    return "A text area with syntax highlight capabilities.";
  }

  /**
   * @see ro.sync.ecss.extensions.api.editor.InplaceEditor#getScrollRectangle()
   */
  @Override
  public Rectangle getScrollRectangle() {
    Rectangle rectangle = null;
    try {
      java.awt.Rectangle modelToView = area.modelToView(area.getCaretPosition());
      rectangle = new Rectangle(modelToView.x, modelToView.y, modelToView.width, modelToView.height);
    } catch (BadLocationException e) {
    }
    return rectangle;
  }

  /**
   * @see ro.sync.ecss.extensions.api.editor.InplaceEditor#requestFocus()
   */
  @Override
  public void requestFocus() {
    area.requestFocus();
  }

  /**
   * @see ro.sync.ecss.extensions.api.editor.InplaceEditor#cancelEditing()
   */
  @Override
  public void cancelEditing() {
    fireEditingCanceled();
  }

  /**
   * @see ro.sync.ecss.extensions.api.editor.InplaceRenderer#getCursorType(ro.sync.ecss.extensions.api.editor.AuthorInplaceContext, int, int)
   */
  @Override
  public CursorType getCursorType(AuthorInplaceContext context, int x, int y) {
    CursorType cursorType = null;
    boolean isSA = true;
    if (context.getAuthorAccess() != null 
        && context.getAuthorAccess().getWorkspaceAccess() != null) {
      isSA = context.getAuthorAccess().getWorkspaceAccess().isStandalone();
    }

    if (isSA) {
      // Check if the cursor is over an area that can start the resize.
      // We only have resize for Standalone.
      RendererLayoutInfo renderingInfo = getRenderingInfo(context);
      java.awt.Rectangle bounds = new java.awt.Rectangle(renderingInfo.getSize().width, renderingInfo.getSize().height);
      // We must see if the mouse is over the scroll border.
      scrollPane.setSize(bounds.width, bounds.height);
      scrollPane.doLayout();
      Component componentAt = scrollPane.getComponentAt(x, y);
      if (componentAt == scrollPane) {
        // We are right over the scroll pane. Not over the text area.
        CursorResizerInfo cursorTypeInfo = componentResizer.getCursorType(new java.awt.Point(x, y), bounds);

        switch (cursorTypeInfo.getCursorType()) {
          case Cursor.SE_RESIZE_CURSOR:
            cursorType = CursorType.CURSOR_SE_RESIZE;
            break;
          case Cursor.E_RESIZE_CURSOR:
            cursorType = CursorType.CURSOR_E_RESIZE;
            break;
          case Cursor.S_RESIZE_CURSOR:
            cursorType = CursorType.CURSOR_S_RESIZE;
            break;
        }
      }
    }
    
    return cursorType;
  }

  /**
   * @see ro.sync.ecss.extensions.api.editor.InplaceRenderer#getCursorType(int, int)
   */
  @Override
  public CursorType getCursorType(int x, int y) {
    return null;
  }
}