##########
# Maodong, generate poleing pattern for LN waveguide.

import numpy as np
import gdspy
import os


def drawPolePad(
        length,
        height,
        padDepth,
        teethHeight,
        dutyCycle=0.5,
        layer=0,
        datatype=0,
):
    # Convention: length in horizontial direction, height in vertical
    # direction. Horiztontial and vertical refer to "E" shaped pad.
    modulationPeriod = teethHeight / dutyCycle
    teethLength = length * padDepth
    gumHeight = modulationPeriod - teethHeight
    gumLength = length - teethLength

    pointsPerTeeth = int(4)  # everyteeth is represented using 4 vertices of a triangle
    numTeeth = int(np.floor(height / modulationPeriod))  # Calculate Num of teeths

    numVertices = pointsPerTeeth * numTeeth + 4  # 4 is vertices at the pad

    # xyArray are array of 2 tuples that will pass to gdspy.Polygen method
    xyArray = [(0, 0)] * int(numVertices)

    # Start with "E" whose leftlower corner is at (0,0)
    # First element is the upperleft corner of the "E" pad.
    xyArray[0] = (0, height)
    xyArray[1] = (gumLength, height)
    xyArray[-2] = (gumLength, 0)
    xyArray[-1] = (0, 0)

    # Next Add teeth corners
    # startTeethUL_y is uppler left corner of the top teeth, y coordinate
    startTeethUL_y = height - ((height - numTeeth * modulationPeriod) / 2 + gumHeight / 2)
    # All upper left vertices
    xyArray[2:-2:pointsPerTeeth] = [(gumLength, startTeethUL_y - ii * modulationPeriod) for ii in range(numTeeth)]
    # All lower left vertices
    xyArray[(1 + pointsPerTeeth):-2:pointsPerTeeth] = [(gumLength, startTeethUL_y - ii * modulationPeriod - teethHeight)
                                                       for ii in range(numTeeth)]

    # upper left and lower left may be modified in future smoothed curve version
    # All upper right vertices
    xyArray[3:-2:pointsPerTeeth] = [(length, startTeethUL_y - ii * modulationPeriod) for ii in range(numTeeth)]
    # All lower right vertices
    xyArray[4:-2:pointsPerTeeth] = [(length, startTeethUL_y - ii * modulationPeriod - teethHeight) for ii in
                                    range(numTeeth)]

    p = gdspy.Polygon(xyArray, layer=layer, datatype=datatype)
    # p.translate(position[0]-length/2, position[1]-height/2)
    return p


if __name__ == "__main__":

    lib = gdspy.GdsLibrary()
    # All subcells will be added to rootCell.
    rootCell = lib.new_cell("Root_cell")

    backGround_layer = 1
    polePad_layer = 2
    waveguide_layer = 10
    text_layer = 4

    # Define Background rectangle on the root cell
    chipSize = (5000, 9000)
    bg = gdspy.Cell('BackGround')
    bg.add(gdspy.Rectangle((0, 0), chipSize, layer=backGround_layer))
    rootCell.add(bg)

    # Create a unit cell for a poling session

    padWidth = 70
    teethLength = 20
    modulationPeriod = 4.53
    dutyCycle = 0.532 / 2.66
    padLength = 4000
    fingerDistance = 10
    waveguideWidth = 2
    # unitWidth = 2*padWidth + fingerDistance

##################### Section 1 #########################
    start_y = 1250
    start_x = 500
    end_y = 3350
    pad_ylist = range(start_y, end_y, padWidth + fingerDistance)
    period_list = np.linspace(1, 20, pad_ylist.__len__())
    # Test draw each instance of the pad
    poleUnit = gdspy.Cell('pole_unit')
    pArray = [drawPolePad(length=padWidth, height=padLength, padDepth=teethLength / padWidth,
                          teethHeight=period_list[ii] * dutyCycle, dutyCycle=dutyCycle, layer=polePad_layer).rotate(angle=-np.pi / 2).mirror((1, 0)).translate(start_x, pad_ylist[ii]) for ii in range(pad_ylist.__len__())]
    pArray[-1] = gdspy.Polygon([(start_x, pad_ylist[-1]), (start_x, pad_ylist[-1]+padWidth),
                                (start_x+padLength, pad_ylist[-1]+padWidth), (start_x+padLength, pad_ylist[-1])], layer=polePad_layer)
    poleUnit.add(pArray)
    rootCell.add(poleUnit)

    textUnit_number = gdspy.Cell('Text_number')
    tArray1 = [gdspy.Text(str(ii), padWidth * 0.7,
                          (start_x - 1.2 * padWidth, (ii - 1) * (padWidth + fingerDistance) + start_y),
                          layer=text_layer) for ii in range(1, 1 + pad_ylist.__len__(), 2)]
    textUnit_number.add(tArray1)
    tArray2 = [gdspy.Text(str(ii), padWidth * 0.7,
                          (start_x + 0.2 * padWidth + padLength, (ii - 1) * (padWidth + fingerDistance) + start_y),
                          layer=text_layer) for ii in range(2, 1 + pad_ylist.__len__(), 2)]
    textUnit_number.add(tArray2)
    rootCell.add(textUnit_number)

    textUnit_period = gdspy.Cell('Text_period')
    tArray3 = [gdspy.Text('p%.2f' % period_list[ii-1], padWidth * 0.2,
                          (start_x - 1.2 * padWidth, (ii - 1) * (padWidth + fingerDistance) + start_y),
                          layer=text_layer) for ii in range(2, 1 + pad_ylist.__len__(), 2)]
    textUnit_period.add(tArray3)
    tArray4 = [gdspy.Text('p%.2f' % period_list[ii-1], padWidth * 0.2,
                          (start_x + 0.2 * padWidth + padLength, (ii - 1) * (padWidth + fingerDistance) + start_y),
                          layer=text_layer) for ii in range(1, 1 + pad_ylist.__len__(), 2)]
    textUnit_period.add(tArray4)
    rootCell.add(textUnit_period)

    wgCell = gdspy.Cell('WaveGuide')
    wgArray = [gdspy.Rectangle((start_x, ii+padWidth+fingerDistance/2-waveguideWidth/2), (start_x+padLength, ii+padWidth+fingerDistance/2+waveguideWidth/2), layer=waveguide_layer) for ii in pad_ylist[0:-1]]
    wgCell.add(wgArray)
    rootCell.add(wgCell)

    ##################### Section 2 #########################
    start_y = 3500-50
    start_x = 500
    end_y = 5500+50
    pad_ylist = range(start_y, end_y, padWidth + fingerDistance)
    period_list = np.linspace(1, 20, pad_ylist.__len__())
    # Test draw each instance of the pad
    poleUnit2 = gdspy.Cell('pole_unit2')
    pArray2 = [drawPolePad(length=padWidth, height=padLength, padDepth=teethLength / padWidth,
                          teethHeight=period_list[ii] * dutyCycle, dutyCycle=dutyCycle, layer=polePad_layer).rotate(
        angle=-np.pi / 2).mirror((1, 0)).translate(start_x, pad_ylist[ii]) for ii in range(pad_ylist.__len__())]
    pArray2[-1] = gdspy.Polygon([(start_x, pad_ylist[-1]), (start_x, pad_ylist[-1] + padWidth),
                                (start_x + padLength, pad_ylist[-1] + padWidth),
                                (start_x + padLength, pad_ylist[-1] )], layer=polePad_layer)
    poleUnit2.add(pArray2)
    rootCell.add(poleUnit2)

    textUnit_number2 = gdspy.Cell('Text_number2')
    tArray1_2 = [gdspy.Text(str(ii), padWidth * 0.7,
                          (start_x - 1.2 * padWidth, (ii - 1) * (padWidth + fingerDistance) + start_y),
                          layer=text_layer) for ii in range(1, 1 + pad_ylist.__len__(), 2)]
    textUnit_number2.add(tArray1_2)
    tArray2_2 = [gdspy.Text(str(ii), padWidth * 0.7,
                          (start_x + 0.2 * padWidth + padLength, (ii - 1) * (padWidth + fingerDistance) + start_y),
                          layer=text_layer) for ii in range(2, 1 + pad_ylist.__len__(), 2)]
    textUnit_number2.add(tArray2_2)
    rootCell.add(textUnit_number2)

    textUnit_period2 = gdspy.Cell('Text_period2')
    tArray3_2 = [gdspy.Text('p%.2f' % period_list[ii - 1], padWidth * 0.2,
                          (start_x - 1.2 * padWidth, (ii - 1) * (padWidth + fingerDistance) + start_y),
                          layer=text_layer) for ii in range(2, 1 + pad_ylist.__len__(), 2)]
    textUnit_period2.add(tArray3_2)
    tArray4_2 = [gdspy.Text('p%.2f' % period_list[ii - 1], padWidth * 0.2,
                          (start_x + 0.2 * padWidth + padLength, (ii - 1) * (padWidth + fingerDistance) + start_y),
                          layer=text_layer) for ii in range(1, 1 + pad_ylist.__len__(), 2)]
    textUnit_period2.add(tArray4_2)
    rootCell.add(textUnit_period2)

    wgCell2 = gdspy.Cell('WaveGuide2')
    wgArray2 = [gdspy.Rectangle((start_x, ii + padWidth + fingerDistance / 2 - waveguideWidth / 2),
                               (start_x + padLength, ii + padWidth + fingerDistance / 2 + waveguideWidth / 2),
                               layer=waveguide_layer) for ii in pad_ylist[0:-1]]
    wgCell2.add(wgArray2)
    rootCell.add(wgCell2)

    ##################### Section 3 #########################
    start_y = 5650
    start_x = 500
    end_y = 7750
    pad_ylist = range(start_y, end_y, padWidth + fingerDistance)
    period_list = np.linspace(1, 20, pad_ylist.__len__())
    # Test draw each instance of the pad
    poleUnit3 = gdspy.Cell('pole_unit3')
    pArray3 = [drawPolePad(length=padWidth, height=padLength, padDepth=teethLength / padWidth,
                          teethHeight=period_list[ii] * dutyCycle, dutyCycle=dutyCycle, layer=polePad_layer).rotate(
        angle=-np.pi / 2).mirror((1, 0)).translate(start_x, pad_ylist[ii]) for ii in range(pad_ylist.__len__())]
    pArray3[-1] = gdspy.Polygon([(start_x, pad_ylist[-1]), (start_x, pad_ylist[-1] + padWidth),
                                (start_x + padLength, pad_ylist[-1] + padWidth),
                                (start_x + padLength, pad_ylist[-1])], layer=polePad_layer)
    poleUnit3.add(pArray3)
    rootCell.add(poleUnit3)

    textUnit_number3 = gdspy.Cell('Text_number3')
    tArray1_3 = [gdspy.Text(str(ii), padWidth * 0.7,
                          (start_x - 1.2 * padWidth, (ii - 1) * (padWidth + fingerDistance) + start_y),
                          layer=text_layer) for ii in range(1, 1 + pad_ylist.__len__(), 2)]
    textUnit_number3.add(tArray1_3)
    tArray2_3 = [gdspy.Text(str(ii), padWidth * 0.7,
                          (start_x + 0.2 * padWidth + padLength, (ii - 1) * (padWidth + fingerDistance) + start_y),
                          layer=text_layer) for ii in range(2, 1 + pad_ylist.__len__(), 2)]
    textUnit_number3.add(tArray2_3)
    rootCell.add(textUnit_number3)

    textUnit_period3 = gdspy.Cell('Text_period3')
    tArray3_3 = [gdspy.Text('p%.2f' % period_list[ii - 1], padWidth * 0.2,
                          (start_x - 1.2 * padWidth, (ii - 1) * (padWidth + fingerDistance) + start_y),
                          layer=text_layer) for ii in range(2, 1 + pad_ylist.__len__(), 2)]
    textUnit_period3.add(tArray3_3)
    tArray4_3 = [gdspy.Text('p%.2f' % period_list[ii - 1], padWidth * 0.2,
                          (start_x + 0.2 * padWidth + padLength, (ii - 1) * (padWidth + fingerDistance) + start_y),
                          layer=text_layer) for ii in range(1, 1 + pad_ylist.__len__(), 2)]
    textUnit_period3.add(tArray4_3)
    rootCell.add(textUnit_period3)

    wgCell3 = gdspy.Cell('WaveGuide3')
    wgArray3 = [gdspy.Rectangle((start_x, ii + padWidth + fingerDistance / 2 - waveguideWidth / 2),
                               (start_x + padLength, ii + padWidth + fingerDistance / 2 + waveguideWidth / 2),
                               layer=waveguide_layer) for ii in pad_ylist[0:-1]]
    wgCell3.add(wgArray3)
    rootCell.add(wgCell3)

########################  4 Corner marker sets ##########################
    cornerMarker_layer = 5
    cornerMarker_localizer_layer = 6
    localizer_list = []

    # poleUnit = gdspy.Cell('pole_unit')
    # p = drawPolePad(length=padWidth, height=padLength, padDepth=teethLength / padWidth,
    #                 teethHeight=modulationPeriod * dutyCycle, dutyCycle=dutyCycle, layer=polePad_layer).rotate(
    #     angle=-np.pi / 2).mirror((1, 0))
    # q = drawPolePad(length=padWidth, height=padLength, padDepth=teethLength / padWidth,
    #                 teethHeight=modulationPeriod * dutyCycle, dutyCycle=dutyCycle, layer=polePad_layer).rotate(
    #     angle=-np.pi / 2).translate(0, unitWidth)
    # w = gdspy.Rectangle((0, unitWidth / 2 - waveguideWidth / 2), (padLength, unitWidth / 2 + waveguideWidth / 2),
    #                     layer=waveguide_layer)
    # poleUnit.add(p)
    # poleUnit.add(q)
    # poleUnit.add(w)
    # rootCell.add(poleUnit)

    gds_filename = "poleing_py_test.gds"
    if os.path.exists(gds_filename):
        os.remove(gds_filename)
    lib.write_gds(gds_filename)
    # gdspy.LayoutViewer(lib)

####################################################
# # Layer/datatype definitions for each step in the fabrication
# cutout = gdspy.Polygon(
#     [(0, 0), (5, 0), (5, 5), (0, 5), (0, 0), (2, 2), (2, 3), (3, 3), (3, 2), (2, 2)]
# )
# ld_fulletch = {"layer": 1, "datatype": 3}
# ld_partetch = {"layer": 2, "datatype": 3}
# ld_liftoff = {"layer": 0, "datatype": 7}
#
# p1 = gdspy.Rectangle((-3, -3), (3, 3), **ld_fulletch)
# p2 = gdspy.Rectangle((-5, -3), (-3, 3), **ld_partetch)
# p3 = gdspy.Rectangle((5, -3), (3, 3), **ld_partetch)
# p4 = gdspy.Round((0, 0), 2.5, number_of_points=6, **ld_liftoff)
#
# # Create a cell with a component that is used repeatedly
# contact = gdspy.Cell("CONTACT")
# contact.add([p1, p2, p3, p4])
#
# # Create a cell with the complete device
# device = gdspy.Cell("DEVICE")
# device.add(cutout)
# # Add 2 references to the component changing size and orientation
# ref1 = gdspy.CellReference(contact, (3.5, 1), magnification=0.25)
# ref2 = gdspy.CellReference(contact, (1, 3.5), magnification=0.25, rotation=90)
# device.add([ref1, ref2])
#
# # The final layout has several repetitions of the complete device
# # main = gdspy.Cell("MAIN")
# rootCell.add(gdspy.CellArray(device, 3, 2, (6, 7)))

